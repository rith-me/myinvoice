FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    libzip-dev libmagickwand-dev mariadb-client nginx supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create necessary directories
RUN mkdir -p /run/php && mkdir -p /var/log/supervisor

# Configure nginx to use Railway's PORT
RUN rm -f /etc/nginx/sites-enabled/default && \
    echo "server { \
        listen ${PORT}; \
        server_name _; \
        root /var/www/html/public; \
        index index.php index.html; \
        location / { \
            try_files \$uri \$uri/ /index.php?\$query_string; \
        } \
        location ~ \.php\$ { \
            include fastcgi_params; \
            fastcgi_pass 127.0.0.1:9000; \
            fastcgi_index index.php; \
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \
        } \
    }" > /etc/nginx/sites-available/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Configure supervisor
RUN echo "[supervisord] \n\
nodaemon=true \n\
[program:php-fpm] \n\
command=/usr/local/sbin/php-fpm -F \n\
[program:nginx] \n\
command=/usr/sbin/nginx -g 'daemon off;'" > /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Install dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Create entrypoint script
RUN echo "#!/bin/bash \n\
php artisan storage:link \n\
php artisan migrate --force \n\
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf" > /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE $PORT

ENTRYPOINT ["/entrypoint.sh"]