# Use stable OpenCart image
FROM aamservices/opencart:4.0.0.0

# Disable debug mode
ENV OPENCART_DEBUG=0

# Copy OpenCart source code
COPY upload/extension/opencart/catalog/view/template/module/featured.html \
/var/www/html/extension/opencart/catalog/view/template/module/featured.html

# Set file permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
