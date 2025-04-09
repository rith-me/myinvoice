FROM php:8.2-fpm

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

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create necessary directories
RUN mkdir -p /run/php && mkdir -p /var/log/supervisor

# Configure NGINX using shell script
RUN rm -f /etc/nginx/sites-enabled/default && \
    echo "server { \
        listen 80; \
        server_name localhost; \
        root /var/www/public; \
        index index.php index.html; \
        location / { \
            try_files \$uri \$uri/ /index.php?\$query_string; \
        } \
        location ~ \.php\$ { \
            include snippets/fastcgi-php.conf; \
            fastcgi_pass unix:/run/php/php-fpm.sock; \
            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name; \
        } \
        location ~ /\.ht { \
            deny all; \
        } \
    }" > /etc/nginx/sites-available/default

# Enable NGINX site
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Supervisor configuration
RUN echo "[supervisord] \n\
nodaemon=true \n\
[program:php-fpm] \n\
command=/usr/local/sbin/php-fpm -F \n\
[program:nginx] \n\
command=/usr/sbin/nginx -g 'daemon off;'" > /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www

# Copy application files into the container
COPY . /var/www

# Expose port
EXPOSE 80

# Start Supervisor (this is what runs the PHP-FPM and NGINX processes)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Run Composer install and Laravel commands at container runtime (use entrypoint script or override CMD in `docker-compose.yml` if needed)
