#!/usr/bin/env bash
set -euo pipefail

HOST="${MYSQL_HOST:-mysql}"
USER="${MYSQL_USER:-root}"
PASS="${MYSQL_PASSWORD:-root}"
DB="sakila"

SCHEMA_FILE="datasets/sakila/sakila-schema.sql"
DATA_FILE="datasets/sakila/sakila-data.sql"

echo "Waiting for MySQL at $HOST..."
until mysqladmin -h "$HOST" -u "$USER" -p"$PASS" ping >/dev/null 2>&1; do
  sleep 2
done

# Check if Sakila is already loaded
if mysql -h "$HOST" -u "$USER" -p"$PASS" -N -e \
  "SELECT 1 FROM information_schema.tables WHERE table_schema='${DB}' AND table_name='actor' LIMIT 1;" \
  | grep -q 1; then
  echo "Sakila already loaded ✅"
  exit 0
fi

echo "Sakila not found. Loading now..."
test -f "$SCHEMA_FILE" || { echo "Missing $SCHEMA_FILE"; exit 1; }
test -f "$DATA_FILE"   || { echo "Missing $DATA_FILE"; exit 1; }

mysql -h "$HOST" -u "$USER" -p"$PASS" < "$SCHEMA_FILE"
mysql -h "$HOST" -u "$USER" -p"$PASS" < "$DATA_FILE"

echo "Sakila loaded ✅"
