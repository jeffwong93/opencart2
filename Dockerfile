# Step 1: Use official PHP Apache image matching OpenCart requirements
FROM php:8.2-apache

# Step 2: Install required system packages and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Configure and install required PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        zip \
        opcache \
        mbstring \
        soap

# Step 4: Enable Apache rewrite module for SEO URLs
RUN a2enmod rewrite

# Step 5: Define the targeted OpenCart version
ENV OPENCART_VERSION=4.0.2.3

# Step 6: Download and extract OpenCart package source safely
WORKDIR /tmp
RUN curl -sSL -o opencart.zip "https://github.com{OPENCART_VERSION}/opencart-${OPENCART_VERSION}.zip" \
    && unzip opencart.zip \
    && rm -rf /var/www/html/* \
    && find . -maxdepth 3 -type d -name "upload" -exec mv {}/* /var/www/html/ \; \
    && rm -rf /tmp/*



# Step 7: Create default empty configuration files
WORKDIR /var/www/html
RUN cp config-dist.php config.php \
    && cp admin/config-dist.php admin/config.php


# Step 8: Set correct ownership permissions for the Apache user
RUN chown -R www-data:www-data /var/www/html

# Step 9: Expose the standard HTTP port
EXPOSE 80

# Step 10: Start Apache in the foreground
CMD ["apache2-foreground"]
