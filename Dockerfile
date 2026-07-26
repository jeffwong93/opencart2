# Use stable OpenCart image
FROM aamservices/opencart:4.0.0.0

# Disable debug mode
ENV OPENCART_DEBUG=0

# Copy OpenCart source code
COPY upload/ /var/www/html/

# Set file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
