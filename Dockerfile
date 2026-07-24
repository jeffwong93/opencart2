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

# 3. Create entrypoint script inline to automatically bypass installation wizard
RUN printf '#!/bin/bash\n\
set -e\n\
\n\
# Force directory structures\n\
mkdir -p /var/www/html/image/cache/\n\
mkdir -p /var/www/html/image/catalog/\n\
chown -R www-data:www-data /var/www/html/image\n\
chmod -R 775 /var/www/html/image\n\
\n\
# BYPASS STEP: Run the silent CLI installation automatically from inside the private subnet\n\
if [ ! -f /var/www/html/config.php ] || [ ! -s /var/www/html/config.php ]; then\n\
  echo "Bypassing wizard: Executing direct OpenCart background installation..."\n\
  php /var/www/html/install/cli_install.php install \\\n\
    --db_driver mysqli \\\n\
    --db_hostname "${DB_HOSTNAME}" \\\n\
    --db_username "${DB_USERNAME}" \\\n\
    --db_password "${DB_PASSWORD}" \\\n\
    --db_database "${DB_DATABASE}" \\\n\
    --db_port 3306 \\\n\
    --db_prefix oc_ \\\n\
    --username "${OC_ADMIN_USER:-admin}" \\\n\
    --password "${OC_ADMIN_PASSWORD:-AdminPass123!}" \\\n\
    --email "${OC_ADMIN_EMAIL:-admin@example.com}" \\\n\
    --http_server "http://localhost/"\n\
  \n\
  # Clean up the install directory for safety\n\
  rm -rf /var/www/html/install\n\
fi\n\
\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

# 4. Make it executable and set it
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
