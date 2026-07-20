# 1. Use a stable OpenCart image
FROM aamservices/opencart:4.0.0.0

# 2. Disable debug mode 
ENV OPENCART_DEBUG=0

# 3. Set correct file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
