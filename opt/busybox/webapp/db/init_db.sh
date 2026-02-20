#!/bin/bash
# Database initialization script - applies all migrations
cd "$(dirname "$0")"
DB_FILE="busyman.db"
echo "Initializing database: $DB_FILE"
for migration in migrations/*.sql; do # Apply all migrations in order
  if [ -f "$migration" ]; then
    echo "  Applying $(basename $migration)..."
    sqlite3 $DB_FILE < "$migration"
    if [ $? -ne 0 ]; then echo "✗ Migration failed: $migration"; exit 1; fi
  fi
done
echo "✓ Database initialized successfully"
echo "  Location: $(pwd)/$DB_FILE"
echo "  Menu items: $(sqlite3 $DB_FILE "SELECT COUNT(*) FROM menu_items;")"
echo "  Settings: $(sqlite3 $DB_FILE "SELECT COUNT(*) FROM settings;" 2>/dev/null || echo "0")"
