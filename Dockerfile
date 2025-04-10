FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Environment variables (optional but helpful if reused multiple times)
ENV HOME_DIR=/home/${user}

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
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install and enable imagick
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create www-data group if it doesn't exist and add user
RUN groupadd -f www-data \
    && useradd -m -u ${uid} -g www-data -d /home/${user} ${user} \
    && mkdir -p /home/${user}/.composer \
    && chown -R ${user}:www-data /home/${user}

# Set working directory
WORKDIR /var/www

# Switch to non-root user
USER ${user}
