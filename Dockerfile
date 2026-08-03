# Use stable OpenCart image
FROM aamservices/opencart:3.0.3.6

# Disable debug mode
ENV OPENCART_DEBUG=0

# Set file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
