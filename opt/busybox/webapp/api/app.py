#!/usr/bin/env python3
"""
Busyman Web App — Flask Backend
Serves NoVNC web interface + API for dynamic menu
"""
from flask import Flask, render_template, jsonify, request, send_from_directory
import sqlite3, os, subprocess, logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'db', 'busyman.db')
TEMPLATE_DIR = os.path.join(BASE_DIR, 'templates')
STATIC_DIR = os.path.join(BASE_DIR, 'static')
NOVNC_DIR = '/opt/busybox/novnc'  # NoVNC library location

app = Flask(__name__, template_folder=TEMPLATE_DIR, static_folder=STATIC_DIR)
app.config['JSON_SORT_KEYS'] = False

def get_db():
    """Get SQLite database connection with row factory."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/')
def index():
    """Serve main HTML page."""
    return render_template('index.html')

@app.route('/novnc/<path:filename>')
def serve_novnc(filename):
    """Serve NoVNC static files."""
    return send_from_directory(NOVNC_DIR, filename)

@app.route('/api/menu')
def get_menu():
    """Get menu items from database."""
    try:
        db = get_db()
        items = db.execute('SELECT * FROM menu_items WHERE visible=1 ORDER BY order_index').fetchall()
        db.close()
        return jsonify([dict(row) for row in items])
    except Exception as e:
        logger.error(f"Failed to fetch menu: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/action', methods=['POST'])
def handle_action():
    """Handle menu item actions."""
    action = request.json.get('action')
    logger.info(f"Action triggered: {action}")
    
    try:
        if action == 'system:reboot':
            subprocess.Popen(['systemctl', 'reboot'])  # non-blocking
            return jsonify({'status': 'rebooting'})
        
        elif action == 'system:stats':
            # CPU/RAM stats (simple implementation)
            cpu = subprocess.check_output(['top', '-bn1', '|', 'head', '-5'], shell=True).decode()
            return jsonify({'status': 'ok', 'data': cpu})
        
        elif action == 'menu:floating':
            return jsonify({'status': 'ok', 'command': 'show_floating_menu'})
        
        elif action == 'system:restart_vnc':
            subprocess.Popen(['systemctl', 'restart', 'vncserver@:98.service'])  # non-blocking
            return jsonify({'status': 'ok', 'message': 'VNC server restarting'})
        
        elif action.startswith('plugin:'):
            # Example: plugin:fb:login → call Busyman API
            parts = action.split(':')
            if len(parts) >= 3:
                plugin, method = parts[1], parts[2]
                # TODO: Call busyman.click_element(f"plugins/{plugin}/img/{method}.png")
                return jsonify({'status': 'ok', 'plugin': plugin, 'method': method})
            else:
                return jsonify({'error': 'invalid_plugin_action'}), 400
        
        else:
            return jsonify({'error': 'unknown_action', 'action': action}), 400
    
    except Exception as e:
        logger.error(f"Action failed: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/health')
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok', 'version': '1.0.0'})

@app.route('/api/settings', methods=['GET', 'POST'])
def handle_settings():
    """Get or update application settings."""
    db = get_db()
    try:
        if request.method == 'GET':
            key = request.args.get('key') # GET single setting or all settings
            if key:
                row = db.execute('SELECT * FROM settings WHERE key=?', (key,)).fetchone()
                db.close()
                if row:
                    return jsonify(dict(row))
                else:
                    return jsonify({'error': 'setting_not_found', 'key': key}), 404
            else: # Return all settings
                rows = db.execute('SELECT * FROM settings ORDER BY key').fetchall()
                db.close()
                return jsonify([dict(row) for row in rows])
        elif request.method == 'POST': # Update setting(s)
            data = request.json
            key = data.get('key')
            value = data.get('value')
            if not key or value is None:
                return jsonify({'error': 'missing_key_or_value'}), 400
            db.execute('''INSERT INTO settings (key, value, updated_at) VALUES (?, ?, CURRENT_TIMESTAMP) ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = CURRENT_TIMESTAMP''', (key, value)) # Update settings table
            if key == 'test_param_a': # Special handling: update menu item label for vnc_resolution
                db.execute('UPDATE menu_items SET label = ? WHERE action = ?', (f'Test Value: {value}', 'info:resolution'))
                logger.info(f"Updated test param menu item label: {value}")
            db.commit()
            db.close()
            logger.info(f"Setting updated: {key} = {value}")
            return jsonify({'status': 'ok', 'key': key, 'value': value})
    except Exception as e:
        logger.error(f"Settings operation failed: {e}")
        db.close()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=8080, debug=True)
