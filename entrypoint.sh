#!/bin/bash

# Run Laravel commands
php artisan config:clear
php artisan config:cache
php artisan storage:link
php artisan migrate --force

# Start Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
