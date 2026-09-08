#!/bin/bash

set -euo pipefail

APP_DIR="${APP_BASE_PATH:-/var/www/html/fuelrod}"

enabled() {
    case "${1,,}" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

artisan() {
    php "${APP_DIR}/artisan" "$@"
}

mkdir -p \
    /tmp/caddy/config \
    /tmp/caddy/data \
    "${APP_DIR}/storage/logs" \
    "${APP_DIR}/storage/framework/cache/data" \
    "${APP_DIR}/storage/framework/sessions" \
    "${APP_DIR}/storage/framework/views" \
    "${APP_DIR}/bootstrap/cache"

if enabled "${LARAVEL_STORAGE_LINK:-true}"; then
    artisan storage:link --force
fi

if enabled "${LARAVEL_MIGRATE:-false}"; then
    artisan migrate --isolated --step --force
fi

for script in /etc/laravel/startup.d/*; do
    [ -e "${script}" ] || continue
    bash "${script}"
done

if enabled "${LARAVEL_OPTIMIZE:-false}"; then
    artisan optimize
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
