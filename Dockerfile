ARG PHP_VERSION=8.4
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine

ARG APP_BASE_PATH=/var/www/html/fuelrod

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp \
    APP_BASE_PATH=${APP_BASE_PATH} \
    APP_PUBLIC_PATH=${APP_BASE_PATH}/public \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_EXECUTION_TIME=60 \
    HORIZON_ENABLED=false \
    SCHEDULER_ENABLED=false \
    LARAVEL_MIGRATE=false \
    LARAVEL_OPTIMIZE=true \
    LARAVEL_STORAGE_LINK=true

RUN apk add --no-cache \
    supervisor \
    bash \
    git \
    curl \
    libcap \
    zip \
    unzip

RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    mbstring \
    opcache \
    pcntl \
    sqlite3 \
    pdo_mysql \
    pdo_sqlite \
    pdo_pgsql \
    redis \
    xml \
    zip \
    && setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/frankenphp

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

LABEL org.opencontainers.image.title="Laravel FrankenPHP Base" \
      org.opencontainers.image.description="Reusable Laravel FrankenPHP runtime with Supervisor" \
      org.opencontainers.image.source="https://github.com/masgeek/laravel-frankenphp-base"

RUN mkdir -p /etc/supervisor/conf.d /etc/frankenphp /etc/laravel/startup.d \
    && mkdir -p /tmp/caddy/config /tmp/caddy/data \
    && mkdir -p \
        "${APP_BASE_PATH}/storage/framework/sessions" \
        "${APP_BASE_PATH}/storage/framework/views" \
        "${APP_BASE_PATH}/storage/framework/cache" \
    && mkdir -p "${APP_BASE_PATH}/storage/logs" \
    && mkdir -p "${APP_BASE_PATH}/bootstrap/cache"

WORKDIR ${APP_BASE_PATH}

COPY docker/php.ini /usr/local/etc/php/conf.d/php.ini
COPY docker/Caddyfile /etc/frankenphp/Caddyfile
COPY supervisor/start.sh /usr/local/bin/start.sh
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/frankenphp.conf /etc/supervisor/conf.d/frankenphp.conf
COPY supervisor/laravel-scheduler.conf /etc/supervisor/conf.d/laravel-scheduler.conf
COPY supervisor/horizon.conf /etc/supervisor/conf.d/horizon.conf

RUN chmod +x /usr/local/bin/start.sh \
    && chown -R www-data:www-data \
        /tmp/caddy \
        "${APP_BASE_PATH}/storage" \
        "${APP_BASE_PATH}/bootstrap/cache"

EXPOSE 80

USER www-data
ENTRYPOINT []
CMD ["/usr/local/bin/start.sh"]
