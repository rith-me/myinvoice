#!/bin/bash

cd /var/www

# Run Laravel setup if needed
composer install --no-dev --optimize-autoloader

php artisan config:cache
php artisan migrate --force
php artisan storage:link

# Start the Laravel dev server
php artisan serve --host=0.0.0.0 --port=8000
