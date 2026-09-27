#!/bin/sh
set -eu
cd /var/www/html
: "${APP_KEY_SEED:?Required}"
: "${DEMO_ADMIN_EMAIL:?Required}"
: "${DEMO_ADMIN_PASSWORD:?Required}"
: "${RENDER_EXTERNAL_URL:?Required}"
export APP_URL="$RENDER_EXTERNAL_URL"
export APP_KEY="$(php -r 'echo "base64:" . base64_encode(hash("sha256", getenv("APP_KEY_SEED"), true));')"
php artisan config:clear --no-interaction
php deploy/initialize.php
mkdir -p public/aimeos
chown -R www-data:www-data storage bootstrap/cache public/aimeos
printf 'Listen 10000\n' > /etc/apache2/ports.conf
exec apache2-foreground
