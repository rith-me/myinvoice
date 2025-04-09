#!/bin/bash

# Laravel Setup
composer install --no-dev --optimize-autoloader
php artisan optimize:clear
php artisan storage:link
php artisan migrate --force

# Run the supervisor (starts nginx + php-fpm)
exec "$@"
