// app.js — Main Application Entry Point v2.0 (Floating Menu + Drag)

import { MenuManager } from "./menu.js";

class BusymanApp {
  constructor() {
    this.menuManager = new MenuManager();
    this.floatingMenu = document.getElementById("floating-menu");
    this.settingsPanel = document.getElementById("settings-panel");
    this.closeBtn = document.querySelector(".close-btn");
    this.minimizeBtn = document.getElementById("minimize-btn");
    this.initialSettings = {};
    this.isDragging = false;
    this.dragOffset = { x: 0, y: 0 };
  }

  initDraggable() {
    const handle = document.getElementById("menu-drag-handle");
    handle.addEventListener("mousedown", (e) => {
      if (e.target.closest(".minimize-btn")) return;
      this.isDragging = true;
      this.floatingMenu.classList.add("dragging");
      const rect = this.floatingMenu.getBoundingClientRect();
      this.dragOffset.x = e.clientX - rect.left;
      this.dragOffset.y = e.clientY - rect.top;
      e.preventDefault();
    });
    document.addEventListener("mousemove", (e) => {
      if (!this.isDragging) return;
      let newX = e.clientX - this.dragOffset.x;
      let newY = e.clientY - this.dragOffset.y;
      const maxX = window.innerWidth - this.floatingMenu.offsetWidth - 10;
      const maxY = window.innerHeight - this.floatingMenu.offsetHeight - 10;
      newX = Math.max(10, Math.min(newX, maxX));
      newY = Math.max(10, Math.min(newY, maxY));
      this.floatingMenu.style.left = newX + "px";
      this.floatingMenu.style.top = newY + "px";
    });
    document.addEventListener("mouseup", () => {
      if (this.isDragging) {
        this.isDragging = false;
        this.floatingMenu.classList.remove("dragging");
        this.saveMenuPosition();
      }
    });
  }

  saveMenuPosition() {
    const pos = { left: this.floatingMenu.style.left, top: this.floatingMenu.style.top };
    localStorage.setItem("busyman_menu_pos", JSON.stringify(pos));
  }

  loadMenuPosition() {
    try {
      const saved = localStorage.getItem("busyman_menu_pos");
      if (saved) {
        const pos = JSON.parse(saved);
        this.floatingMenu.style.left = pos.left;
        this.floatingMenu.style.top = pos.top;
      }
    } catch (e) { console.warn("Could not load menu position:", e); }
  }

  initMinimize() {
    const isMinimized = localStorage.getItem("busyman_menu_minimized") === "true";
    if (isMinimized) this.floatingMenu.classList.add("minimized");
    this.updateMinimizeBtn();
    this.minimizeBtn.addEventListener("click", () => {
      this.floatingMenu.classList.toggle("minimized");
      const minimized = this.floatingMenu.classList.contains("minimized");
      localStorage.setItem("busyman_menu_minimized", minimized);
      this.updateMinimizeBtn();
    });
  }

  updateMinimizeBtn() {
    const isMin = this.floatingMenu.classList.contains("minimized");
    this.minimizeBtn.textContent = isMin ? "+" : "−";
    this.minimizeBtn.setAttribute("aria-label", isMin ? "Expand" : "Minimize");
  }

  initSettingsPanel() {
    this.closeBtn.addEventListener("click", () => this.settingsPanel.classList.remove("active"));
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape" && this.settingsPanel.classList.contains("active")) {
        this.settingsPanel.classList.remove("active");
      }
    });
    document.getElementById("apply-settings").addEventListener("click", async () => {
      const resolution = document.getElementById("test-param-a").value;
      const displayMode = document.getElementById("display-mode").value;
      const quality = document.getElementById("quality").value;
      if (resolution === this.initialSettings.test_param_a && 
          displayMode === this.initialSettings.display_mode && 
          quality === this.initialSettings.quality) {
        alert("No changes detected.");
        return;
      }
      try {
        await Promise.all([
          fetch("/api/settings", {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify({key: "test_param_a", value: resolution})}),
          fetch("/api/settings", {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify({key: "display_mode", value: displayMode})}),
          fetch("/api/settings", {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify({key: "quality", value: quality})})
        ]);
        this.initialSettings = {test_param_a: resolution, display_mode: displayMode, quality};
        this.settingsPanel.classList.remove("active");
      } catch (error) {
        console.error("Failed to save settings:", error);
        alert("Failed to save settings.");
      }
    });
    document.getElementById("quality").addEventListener("input", (e) => {
      document.getElementById("quality-value").textContent = e.target.value;
    });
    document.getElementById("restart-vnc").addEventListener("click", async () => {
      if (!confirm("Restart VNC Server?")) return;
      try {
        const res = await fetch("/api/action", {method: "POST", headers: {"Content-Type": "application/json"}, body: JSON.stringify({action: "system:restart_vnc"})});
        const result = await res.json();
        if (result.status === "ok") { alert("VNC restarting..."); this.settingsPanel.classList.remove("active"); }
        else { alert("Failed: " + (result.error || "Unknown error")); }
      } catch (error) { alert("Failed to restart VNC."); }
    });
  }

  async initNoVNC() {
    const statusDiv = document.getElementById("novnc-status");
    const statusText = document.querySelector(".status-text");
    const statusIndicator = document.querySelector(".status-indicator");
    try {
      const {default: RFB} = await import("/novnc/core/rfb.js");
      const rfb = new RFB(document.getElementById("screen"), "ws://localhost:6080");
      rfb.scaleViewport = true;
      rfb.resizeSession = false;
      rfb.addEventListener("connect", () => {
        statusDiv.style.display = "none";
        console.log("NoVNC connected");
      });
      rfb.addEventListener("disconnect", () => {
        statusDiv.style.display = "flex";
        statusText.textContent = "VNC Disconnected";
        statusIndicator.classList.remove("connected");
        statusIndicator.classList.add("error");
      });
      this.vncClient = rfb;
    } catch (error) {
      statusDiv.style.display = "flex";
      statusText.textContent = "Failed to load NoVNC";
      statusIndicator.classList.add("error");
      console.error("NoVNC error:", error);
    }
  }

  async loadSettings() {
    try {
      const res = await fetch("/api/settings");
      const settings = await res.json();
      settings.forEach(s => {
        const el = document.getElementById(s.key.replace("_", "-"));
        if (el) {
          el.value = s.value;
          this.initialSettings[s.key] = s.value;
          if (s.key === "quality") document.getElementById("quality-value").textContent = s.value;
        }
      });
    } catch (e) { console.error("Failed to load settings:", e); }
  }

  async init() {
    console.log("Busyman v2.0 starting...");
    this.loadMenuPosition();
    this.initDraggable();
    this.initMinimize();
    await this.loadSettings();
    this.menuManager.start();
    this.initSettingsPanel();
    this.initNoVNC();
    console.log("Busyman v2.0 ready");
  }
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => new BusymanApp().init());
} else {
  new BusymanApp().init();
}
