FROM php:8.1-fpm

# Arguments defined in docker-compose.yml (Optional)
# ARG user
# ARG uid

# Set default values for uid and user
ENV user=myuser
ENV uid=1000

# Install system dependencies (including nginx)
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
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl bcmath gd

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

# Copy nginx configuration (you'll need to add this)
# COPY ./nginx.conf /etc/nginx/nginx.conf

# Expose HTTP port
EXPOSE 80

# Start the services
CMD ["nginx", "-g", "daemon off;"]