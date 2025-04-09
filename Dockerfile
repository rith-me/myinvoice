FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libmagickwand-dev \
    mariadb-client \
    nginx \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Configure nginx
RUN echo "server {
    listen 80;
    server_name localhost;
    root /var/www/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass unix:/run/php/php-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}" > /etc/nginx/sites-available/default

# Supervisor configuration
RUN mkdir -p /var/log/supervisor
RUN echo "[supervisord]
nodaemon=true

[program:php-fpm]
command=/usr/local/sbin/php-fpm

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
" > /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www

# Expose port 80
EXPOSE 80

# Start supervisor
CMD ["/usr/bin/supervisord"]
