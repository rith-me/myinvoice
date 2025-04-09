#!/bin/bash
# Install Composer dependencies and run Laravel commands
/usr/local/bin/composer install --no-dev --optimize-autoloader
php artisan optimize:clear
php artisan storage:link
php artisan migrate --force

# Start the main command (Supervisor)
exec "$@"
