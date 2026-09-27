FROM node:22-bookworm-slim AS assets
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM php:8.4-apache-bookworm
RUN apt-get update && apt-get install -y --no-install-recommends \
    git unzip libicu-dev libzip-dev libpq-dev libonig-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j2 intl zip pdo_pgsql mbstring gd bcmath opcache \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
WORKDIR /var/www/html
COPY . .
# Explicit commands avoid interactive create-project hooks and account-side effects.
RUN composer install --no-dev --prefer-dist --no-interaction --no-scripts --optimize-autoloader \
    && php artisan package:discover --no-interaction \
    && php artisan vendor:publish --tag=public --force --no-interaction \
    && php artisan vendor:publish --tag=laravel-assets --force --no-interaction
COPY --from=assets /app/public/build ./public/build
COPY deploy/apache.conf /etc/apache2/sites-available/000-default.conf
RUN mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/tmp \
    && chown -R www-data:www-data storage bootstrap/cache public \
    && chmod +x deploy/start.sh
EXPOSE 10000
CMD ["/var/www/html/deploy/start.sh"]
