FROM php:8.1-fpm

# Arguments (optional for custom user setup)
ARG user=crater-user
ARG uid=1000

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl libpng-dev libonig-dev libxml2-dev zip unzip \
    libzip-dev libmagickwand-dev mariadb-client \
    libjpeg-dev libfreetype6-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Install Imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Copy Composer from the Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy project files
COPY . .

# Set permissions (adjust as needed)
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www

# Optional: Set entrypoint script if you have it
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose port 80
EXPOSE 80

# Set default user
USER www-data
