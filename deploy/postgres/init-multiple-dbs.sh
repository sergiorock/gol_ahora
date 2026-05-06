#!/bin/sh
set -eu

if [ -z "${POSTGRES_MULTIPLE_DATABASES:-}" ]; then
  exit 0
fi

IFS=','
for db in $POSTGRES_MULTIPLE_DATABASES; do
  db=$(printf '%s' "$db" | xargs)

  if [ -z "$db" ]; then
    continue
  fi

  echo "Ensuring database exists: $db"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<SQL
SELECT 'CREATE DATABASE "$db"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
SQL
done
