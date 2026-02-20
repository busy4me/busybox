// app.js — Main Application Entry Point

import { MenuManager } from './menu.js';

class BusymanApp {
  constructor() {
    this.menuManager = new MenuManager();
    this.floatingMenu = document.getElementById('floating-menu');
    this.closeBtn = document.querySelector('.close-btn');
    this.initialSettings = {}; // Store initial settings for change detection
  }

  initFloatingMenu() {
    // Close button handler
    this.closeBtn.addEventListener('click', () => {
      this.floatingMenu.classList.remove('active');
    });

    // Close on Escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape' && this.floatingMenu.classList.contains('active')) {
        this.floatingMenu.classList.remove('active');
      }
    });

    // Apply settings button
    document.getElementById('apply-settings').addEventListener('click', async () => {
      const resolution = document.getElementById('vnc-resolution').value;
      const displayMode = document.getElementById('display-mode').value;
      const quality = document.getElementById('quality').value;
      if (resolution === this.initialSettings.vnc_resolution && displayMode === this.initialSettings.display_mode && quality === this.initialSettings.quality) { alert('No changes detected. Please modify settings before applying.'); return; } // Validation: check if anything changed
      try { // Save all settings to database
        const promises = [
          fetch('/api/settings', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({key: 'vnc_resolution', value: resolution})}),
          fetch('/api/settings', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({key: 'display_mode', value: displayMode})}),
          fetch('/api/settings', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({key: 'quality', value: quality})})
        ];
        await Promise.all(promises);
        this.initialSettings = {vnc_resolution: resolution, display_mode: displayMode, quality}; // Update initial settings
        console.log('Settings saved successfully:', {resolution, displayMode, quality});
        this.floatingMenu.classList.remove('active'); // Close floating menu (menu will auto-refresh within 5s via polling)
      } catch (error) {
        console.error('Failed to save settings:', error);
        alert('Failed to save settings. Please try again.');
      }
    });

    // Quality slider live update
    document.getElementById('quality').addEventListener('input', (e) => {
      document.getElementById('quality-value').textContent = e.target.value;
    });

    // Restart VNC button
    document.getElementById('restart-vnc').addEventListener('click', async () => {
      if (!confirm('Restart VNC Server? This will disconnect all VNC clients for ~5 seconds.')) return;
      try {
        const response = await fetch('/api/action', {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify({action: 'system:restart_vnc'})});
        const result = await response.json();
        if (result.status === 'ok') { alert('VNC server restarting...'); this.floatingMenu.classList.remove('active'); }
        else { alert('Failed to restart VNC: ' + (result.error || 'Unknown error')); }
      } catch (error) {
        console.error('Failed to restart VNC:', error);
        alert('Failed to restart VNC. Please try again.');
      }
    });
  }

  async initNoVNC() {
    const statusDiv = document.getElementById('novnc-status');
    const statusText = document.querySelector('.status-text');
    const statusIndicator = document.querySelector('.status-indicator');
    try {
      const {default: RFB} = await import('/novnc/core/rfb.js');  // Import NoVNC RFB module
      const rfb = new RFB(document.getElementById('screen'), 'ws://localhost:6080');
      rfb.scaleViewport = true;  // Scale viewport to fit container
      rfb.resizeSession = false;  // Don't resize remote session
      rfb.addEventListener('connect', () => {
        statusDiv.style.display = 'none';  // Hide status on successful connect
        console.log('NoVNC connected successfully');
      });
      rfb.addEventListener('disconnect', () => {
        statusDiv.style.display = 'flex';  // Show status on disconnect
        statusText.textContent = 'VNC Disconnected';
        statusIndicator.classList.remove('connected');
        statusIndicator.classList.add('error');
        console.log('NoVNC disconnected');
      });
      this.vncClient = rfb;  // Store for settings adjustments
    } catch (error) {
      statusDiv.style.display = 'flex';  // Show status on error
      statusText.textContent = 'Failed to load NoVNC';
      statusIndicator.classList.add('error');
      console.error('NoVNC initialization error:', error);
    }
  }

  async loadSettings() {
    try {
      const response = await fetch('/api/settings');
      const settings = await response.json();
      settings.forEach(setting => { // Populate form fields with current values
        const element = document.getElementById(setting.key.replace('_', '-'));
        if (element) {
          element.value = setting.value;
          this.initialSettings[setting.key] = setting.value; // Store initial value
          if (setting.key === 'quality') { document.getElementById('quality-value').textContent = setting.value; } // Update quality display
        }
      });
      console.log('Settings loaded:', settings);
    } catch (error) { console.error('Failed to load settings:', error); }
  }

  async init() {
    console.log('Busyman Web App starting...');
    await this.loadSettings(); // Load current settings from database
    this.menuManager.start(); // Start menu polling
    this.initFloatingMenu(); // Initialize floating menu
    this.initNoVNC(); // Initialize NoVNC
    console.log('Busyman Web App ready');
  }
}

// Start app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    const app = new BusymanApp();
    app.init();
  });
} else {
  const app = new BusymanApp();
  app.init();
}
