#!/usr/bin/env bash
set -e

HOST="db"
USER="root"
PASSWORD="root"
DB="sakila"

echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h"$HOST" -u"$USER" -p"$PASSWORD" --silent; do
  sleep 2
done

echo "MySQL is ready."

SCHEMA_FILE="datasets/sakila-schema.sql"
DATA_FILE="datasets/sakila-data.sql"

if [ ! -f "$SCHEMA_FILE" ] || [ ! -f "$DATA_FILE" ]; then
  echo "Sakila files not found in datasets/."
  echo "Please add:"
  echo "  datasets/sakila-schema.sql"
  echo "  datasets/sakila-data.sql"
  exit 0
fi

TABLE_COUNT=$(mysql -h"$HOST" -u"$USER" -p"$PASSWORD" -Nse \
  "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='${DB}';")

if [ "$TABLE_COUNT" -gt 0 ]; then
  echo "Sakila already loaded."
  exit 0
fi

echo "Loading Sakila schema..."
mysql -h"$HOST" -u"$USER" -p"$PASSWORD" "$DB" < "$SCHEMA_FILE"

echo "Loading Sakila data..."
mysql -h"$HOST" -u"$USER" -p"$PASSWORD" "$DB" < "$DATA_FILE"

echo "Sakila loaded successfully."
