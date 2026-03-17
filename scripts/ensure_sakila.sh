#!/usr/bin/env bash
set -euo pipefail

HOST="mysql"
USER="root"
PASSWORD="root"
DB="sakila"

SCHEMA_FILE="datasets/sakila/sakila-schema.sql"
DATA_FILE="datasets/sakila/sakila-data.sql"

echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h"$HOST" -u"$USER" -p"$PASSWORD" --silent; do
  sleep 2
done

echo "MySQL is ready."

if [ ! -f "$SCHEMA_FILE" ] || [ ! -f "$DATA_FILE" ]; then
  echo "Sakila files not found."
  echo "Expected:"
  echo "  $SCHEMA_FILE"
  echo "  $DATA_FILE"
  exit 1
fi

TABLE_EXISTS=$(mysql -h"$HOST" -u"$USER" -p"$PASSWORD" -Nse \
  "SELECT COUNT(*)
   FROM information_schema.tables
   WHERE table_schema='${DB}'
     AND table_name='actor';")

if [ "$TABLE_EXISTS" -gt 0 ]; then
  echo "Sakila already loaded."
  exit 0
fi

echo "Loading Sakila schema..."
mysql -h"$HOST" -u"$USER" -p"$PASSWORD" "$DB" < "$SCHEMA_FILE"

echo "Loading Sakila data..."
mysql -h"$HOST" -u"$USER" -p"$PASSWORD" "$DB" < "$DATA_FILE"

echo "Sakila loaded successfully."
