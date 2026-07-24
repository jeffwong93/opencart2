FROM aamservices/opencart:3.0.3.8

# 1. Inject production PHP settings
RUN echo "display_errors = Off;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "upload_max_filesize = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "post_max_size = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini

# 2. Standard build-time permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# 3. Create entrypoint script inline to avoid missing file errors
RUN printf '#!/bin/bash\n\
set -e\n\
mkdir -p /var/www/html/image/cache/\n\
mkdir -p /var/www/html/image/catalog/\n\
chown -R www-data:www-data /var/www/html/image\n\
chmod -R 775 /var/www/html/image\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

# 4. Make it executable and set it
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
