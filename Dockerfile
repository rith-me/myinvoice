# For Nginx instead of Apache
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y nginx
# Install PHP extensions
RUN docker-php-ext-install pdo_mysql zip gd mbstring exif pcntl bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy files
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN composer install --optimize-autoloader --no-dev
RUN npm install && npm run production

# Permissions
RUN chown -R www-data:www-data /var/www/html/storage
RUN chmod -R 775 /var/www/html/storage

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8080

CMD service nginx start && php-fpm