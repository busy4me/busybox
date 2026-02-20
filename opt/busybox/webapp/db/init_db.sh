#!/bin/bash
# Initialize Busyman Web App database
set -e
DB_DIR=$(dirname "$0")
DB_FILE="$DB_DIR/busyman.db"
MIGRATION="$DB_DIR/migrations/001_initial_schema.sql"
if [ -f "$DB_FILE" ]; then echo "Database already exists: $DB_FILE"; else sqlite3 "$DB_FILE" < "$MIGRATION" && echo "✅ Database initialized: $DB_FILE"; fi
