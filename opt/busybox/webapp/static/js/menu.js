// menu.js — Dynamic Menu Updates

export class MenuManager {
  constructor() {
    this.menuContainer = document.getElementById('menu-items');
    this.updateInterval = 5000; // 5s polling
    this.intervalId = null;
  }

  async fetchMenu() {
    try {
      const res = await fetch('/api/menu');
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return await res.json();
    } catch (err) {
      console.error('Failed to fetch menu:', err);
      return [];
    }
  }

  renderMenu(items) {
    if (!items || items.length === 0) {
      this.menuContainer.innerHTML = '<div class="menu-item-skeleton">No menu items</div>';
      return;
    }

    this.menuContainer.innerHTML = items.map(item => `
      <div class="menu-item" data-action="${item.action}" data-id="${item.id}">
        <span class="emoji">${item.emoji || '●'}</span>
        <span class="label">${item.label}</span>
      </div>
    `).join('');
  }

  async handleAction(action) {
    console.log(`Triggering action: ${action}`);
    
    try {
      const res = await fetch('/api/action', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({action})
      });
      
      const result = await res.json();
      
      if (result.command === 'show_floating_menu') {
        document.getElementById('floating-menu').classList.add('active');
      }
      
      return result;
    } catch (err) {
      console.error('Action failed:', err);
      return {error: err.message};
    }
  }

  attachEventHandlers() {
    this.menuContainer.addEventListener('click', async (e) => {
      const menuItem = e.target.closest('.menu-item');
      if (!menuItem) return;
      document.querySelectorAll('.menu-item').forEach(el => el.classList.remove('active')); // Visual feedback
      menuItem.classList.add('active');
      const action = menuItem.dataset.action;
      if (action === 'info:resolution') { document.getElementById('floating-menu').classList.add('active'); return; } // Special handling for info actions (open floating menu directly)
      await this.handleAction(action);
    });
  }

  async update() {
    const items = await this.fetchMenu();
    this.renderMenu(items);
  }

  start() {
    this.update(); // Initial load
    this.attachEventHandlers();
    this.intervalId = setInterval(() => this.update(), this.updateInterval);
    console.log(`Menu polling started (${this.updateInterval}ms)`);
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
      console.log('Menu polling stopped');
    }
  }
}
