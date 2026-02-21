#!/bin/bash
# Database initialization script - applies all migrations with tracking
cd "$(dirname "$0")"
DB_FILE="busyman.db"
# Create migration tracker table
sqlite3 $DB_FILE << 'EOF'
CREATE TABLE IF NOT EXISTS migrations_applied (
    migration_name TEXT PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF
echo "Initializing database: $DB_FILE"
for migration in migrations/*.sql; do
  if [ -f "$migration" ]; then
    migration_name=$(basename "$migration")
    already_applied=$(sqlite3 $DB_FILE "SELECT COUNT(*) FROM migrations_applied WHERE migration_name='$migration_name';")
    if [ "$already_applied" -eq 0 ]; then
      echo "  Applying $migration_name..."
      sqlite3 $DB_FILE < "$migration"
      if [ $? -ne 0 ]; then echo "✗ Migration failed: $migration_name"; exit 1; fi
      sqlite3 $DB_FILE "INSERT INTO migrations_applied (migration_name) VALUES ('$migration_name');"
      echo "  ✓ Applied $migration_name"
    else
      echo "  ⊘ Skipped $migration_name (already applied)"
    fi
  fi
done
echo "✓ Database initialized successfully"
echo "  Location: $(pwd)/$DB_FILE"
echo "  Menu items: $(sqlite3 $DB_FILE "SELECT COUNT(*) FROM menu_items;")"
echo "  Settings: $(sqlite3 $DB_FILE "SELECT COUNT(*) FROM settings;" 2>/dev/null || echo "0")"
