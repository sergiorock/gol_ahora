#!/bin/bash
set -e

rm -f /rails/tmp/pids/server.pid

# En desarrollo crea la DB y corre migraciones automáticamente.
# En producción el workflow de deploy corre db:prepare por separado.
if [ "$RAILS_ENV" = "development" ]; then
  bundle exec rails db:prepare
  bundle exec rails db:seed
fi

exec bundle exec "$@"
