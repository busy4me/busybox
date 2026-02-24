#!/bin/bash
# Database initialization script - applies all migrations with tracking
set -e

cd "$(dirname "$0")"
DB_FILE="busyman.db"

# Check if sqlite3 is installed
if ! command -v sqlite3 &> /dev/null; then
    echo "ERROR: sqlite3 command not found"
    exit 1
fi

echo "Initializing database: $DB_FILE"
echo "Current directory: $(pwd)"

# Create migration tracker table
echo "Creating migrations_applied table..."
sqlite3 -batch $DB_FILE << 'EOF'
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
CREATE TABLE IF NOT EXISTS migrations_applied (
    migration_name TEXT PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

if [ ! -f "$DB_FILE" ]; then
    echo "ERROR: Failed to create database file $DB_FILE"
    exit 1
fi

# Check file size immediately
echo "Database size after creation: $(stat -c%s "$DB_FILE" 2>/dev/null || ls -l "$DB_FILE" | awk '{print $5}') bytes"

# Check migrations directory
if [ ! -d "migrations" ]; then
    echo "WARNING: migrations directory not found"
else
    echo "Applying migrations from $(pwd)/migrations/..."
    # Enable nullglob to handle empty directory
    shopt -s nullglob
    migrations=(migrations/*.sql)
    
    if [ ${#migrations[@]} -eq 0 ]; then
        echo "No .sql migration files found in migrations/"
    else
        for migration in "${migrations[@]}"; do
            migration_name=$(basename "$migration")
            already_applied=$(sqlite3 -batch $DB_FILE "SELECT COUNT(*) FROM migrations_applied WHERE migration_name='$migration_name';")
            
            if [ "$already_applied" -eq 0 ]; then
                echo "  Applying $migration_name..."
                # Use cat to pipe to ensure file is read
                cat "$migration" | sqlite3 -batch $DB_FILE
                
                sqlite3 -batch $DB_FILE "INSERT INTO migrations_applied (migration_name) VALUES ('$migration_name');"
                echo "  ✓ Applied $migration_name"
            else
                echo "  ⊘ Skipped $migration_name (already applied)"
            fi
        done
    fi
fi

# Force write to disk
sync

echo "✓ Database initialization completed"
echo "  Location: $(pwd)/$DB_FILE"
echo "  Final Size: $(stat -c%s "$DB_FILE" 2>/dev/null || ls -l "$DB_FILE" | awk '{print $5}') bytes"
echo "  Tables: $(sqlite3 -batch $DB_FILE "SELECT name FROM sqlite_master WHERE type='table';")"

