# 1. Use a verified public OpenCart image built with Apache and PHP
FROM aamservices/opencart:3.0.5.0

# 2. Prevent OpenCart from running in developer mode and optimize for production
ENV OPENCART_DEBUG=0

# 3. Correct ownership so Apache can read and write to the pre-configured application files
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
