// app.js — Main Application Entry Point

import { MenuManager } from './menu.js';

class BusymanApp {
  constructor() {
    this.menuManager = new MenuManager();
    this.floatingMenu = document.getElementById('floating-menu');
    this.closeBtn = document.querySelector('.close-btn');
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
    document.getElementById('apply-settings').addEventListener('click', () => {
      const resolution = document.getElementById('vnc-resolution').value;
      const displayMode = document.getElementById('display-mode').value;
      const quality = document.getElementById('quality').value;
      
      console.log('Settings applied:', {resolution, displayMode, quality});
      
      // TODO: Apply to NoVNC client
      // this.vncClient.changeResolution(resolution);
      // this.vncClient.setQuality(quality);
      
      this.floatingMenu.classList.remove('active');
    });

    // Quality slider live update
    document.getElementById('quality').addEventListener('input', (e) => {
      document.getElementById('quality-value').textContent = e.target.value;
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

  async init() {
    console.log('Busyman Web App starting...');
    
    // Start menu polling
    this.menuManager.start();
    
    // Initialize floating menu
    this.initFloatingMenu();
    
    // Initialize NoVNC (placeholder for now)
    this.initNoVNC();
    
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
