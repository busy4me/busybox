-- Migration 001: Initial Schema
-- Created: 2026-02-20
-- Description: Create menu_items table with sample data

CREATE TABLE IF NOT EXISTS menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  label TEXT NOT NULL,
  emoji TEXT,
  icon_path TEXT,
  action TEXT NOT NULL,
  order_index INTEGER DEFAULT 0,
  visible BOOLEAN DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample menu items
INSERT INTO menu_items (label, emoji, action, order_index) VALUES
  ('Reboot', '🔄', 'system:reboot', 1),
  ('Stats', '📊', 'system:stats', 2),
  ('Settings', '⚙️', 'menu:floating', 3);

-- Create index on order_index for faster queries
CREATE INDEX IF NOT EXISTS idx_menu_order ON menu_items(order_index, visible);
