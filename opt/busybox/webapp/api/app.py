#!/usr/bin/env python3
"""
Busyman Web App — Flask Backend
Serves NoVNC web interface + API for dynamic menu
"""
from flask import Flask, render_template, jsonify, request
import sqlite3, os, subprocess, logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, 'db', 'busyman.db')
TEMPLATE_DIR = os.path.join(BASE_DIR, 'templates')
STATIC_DIR = os.path.join(BASE_DIR, 'static')

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

if __name__ == '__main__':
    # Development server
    app.run(host='0.0.0.0', port=8080, debug=True)
