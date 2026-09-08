# Laravel FrankenPHP Base Image

Reusable production base image for Laravel applications running FrankenPHP,
Supervisor, Horizon, and the Laravel scheduler.

## Build

```bash
docker build \
  --build-arg PHP_VERSION=8.4 \
  --build-arg APP_BASE_PATH=/var/www/html/app \
  -t ghcr.io/masgeek/laravel-frankenphp-base:php8.4-v1 .
```

The image provides the PHP runtime, extensions, Composer, FrankenPHP, Caddy,
Supervisor, and generic process configuration. Application source code and
Composer dependencies are supplied by the consuming Laravel application image.

## Runtime Variables

| Variable | Default | Purpose |
|---|---|---|
| `APP_BASE_PATH` | `/var/www/html/fuelrod` | Application root inside the image |
| `APP_PUBLIC_PATH` | `${APP_BASE_PATH}/public` | Public document root |
| `HORIZON_ENABLED` | `false` | Enable the Horizon Supervisor program |
| `SCHEDULER_ENABLED` | `false` | Enable the scheduler Supervisor program |
| `LARAVEL_MIGRATE` | `false` | Run migrations during startup |
| `LARAVEL_OPTIMIZE` | `true` | Run `artisan optimize` during startup |
| `LARAVEL_STORAGE_LINK` | `true` | Run `artisan storage:link` during startup |

Migrations should normally run as a separate deployment step, not from every
web container startup.

## Release Policy

Publish immutable version tags such as:

```text
ghcr.io/masgeek/laravel-frankenphp-base:php8.4-v1.0.0
```

Applications should consume an explicit version tag or digest rather than
`latest`.
