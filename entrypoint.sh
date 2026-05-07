#!/bin/bash
set -e

rm -f /rails/tmp/pids/server.pid

bundle exec rails db:prepare
bundle exec rails db:seed

exec bundle exec "$@"
