-- Migration 002: Settings table + dynamic resolution menu item
-- Author: Dariusz Porczyński
-- Date: 2026-02-20

-- Settings table
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  label TEXT,
  type TEXT DEFAULT 'string',
  min_value INTEGER,
  max_value INTEGER,
  options TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initial settings
INSERT OR IGNORE INTO settings (key, value, label, type, options) VALUES 
  ('vnc_resolution', '1920x1080', 'VNC Resolution', 'enum', '["1920x1080", "1280x720", "1024x768", "800x600"]'),
  ('display_mode', 'scale', 'Display Mode', 'enum', '["scale", "native"]'),
  ('quality', '6', 'Quality', 'number', NULL);

-- Update quality with min/max
UPDATE settings SET min_value = 0, max_value = 9 WHERE key = 'quality';

-- Add dynamic resolution menu item
INSERT OR IGNORE INTO menu_items (label, emoji, action, order_index, visible) VALUES 
  ('Resolution: 1920x1080', '📐', 'info:resolution', 4, 1);
