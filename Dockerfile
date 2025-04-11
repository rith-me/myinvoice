# Dockerfile នៅក្នុង myinvoice/
FROM php:8.2-fpm

# Dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libonig-dev libxml2-dev libzip-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN php artisan optimize:clear && php artisan storage:link

EXPOSE 9000
CMD ["php-fpm"]
