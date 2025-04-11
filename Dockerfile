FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG user=crater-user
ARG uid=1000

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
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Copy Composer from the Composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set the entrypoint to your custom script
ENTRYPOINT ["/entrypoint.sh"]

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory and permissions
WORKDIR /var/www
RUN chown -R www-data:www-data /var/www
RUN chmod -R 755 /var/www

USER $user
