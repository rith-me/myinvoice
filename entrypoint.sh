#!/bin/bash

cd /var/www

composer install --no-dev --optimize-autoloader
php artisan config:cache
php artisan migrate --force
php artisan storage:link

php artisan serve --host=0.0.0.0 --port=8000
