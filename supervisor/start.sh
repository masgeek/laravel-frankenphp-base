#!/bin/bash

set -euo pipefail

APP_DIR="${APP_BASE_PATH:-/var/www/html/fuelrod}"

log() {
    echo "[startup] $(date '+%Y-%m-%d %H:%M:%S') $*"
}

log "========================================"
log "Fuelrod container startup"
log "========================================"
log "APP_DIR=${APP_DIR}"
log "LARAVEL_STORAGE_LINK=${LARAVEL_STORAGE_LINK:-true}"
log "LARAVEL_MIGRATE=${LARAVEL_MIGRATE:-false}"
log "LARAVEL_OPTIMIZE=${LARAVEL_OPTIMIZE:-false}"

enabled() {
    case "${1,,}" in
        1|true|yes|on) return 0 ;;
        *) return 1 ;;
    esac
}

artisan() {
    log "Running: php artisan $*"
    php "${APP_DIR}/artisan" "$@"
}

log "Creating required directories..."

mkdir -p \
    /tmp/caddy/config \
    /tmp/caddy/data \
    "${APP_DIR}/storage/logs" \
    "${APP_DIR}/storage/framework/cache/data" \
    "${APP_DIR}/storage/framework/sessions" \
    "${APP_DIR}/storage/framework/views" \
    "${APP_DIR}/bootstrap/cache"

log "Required directories ready."

if enabled "${LARAVEL_STORAGE_LINK:-true}"; then
    log "Creating Laravel storage symlink..."
    artisan storage:link --force
    log "Laravel storage symlink created."
else
    log "Laravel storage link disabled."
fi

if enabled "${LARAVEL_MIGRATE:-false}"; then
    log "Running database migrations..."
    artisan migrate --isolated --step --force
    log "Database migrations completed."
else
    log "Database migrations disabled."
fi

log "Running startup scripts..."

for script in /etc/laravel/startup.d/*; do
    [ -e "${script}" ] || continue

    log "----------------------------------------"
    log "Running startup script: ${script}"
    log "----------------------------------------"

    bash "${script}"

    log "Completed startup script: ${script}"
done

log "Startup scripts completed."

if enabled "${LARAVEL_OPTIMIZE:-false}"; then
    log "Optimizing Laravel application..."
    artisan optimize
    log "Laravel optimization completed."
else
    log "Laravel optimization disabled."
fi

log "========================================"
log "Startup initialization complete"
log "Starting supervisord..."
log "========================================"

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf