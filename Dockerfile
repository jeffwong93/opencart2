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

# 3. Create entrypoint script with automatic fallback mappings
RUN printf '#!/bin/bash\n\
set -e\n\
\n\
# Force directory structures\n\
mkdir -p /var/www/html/image/cache/\n\
mkdir -p /var/www/html/image/catalog/\n\
chown -R www-data:www-data /var/www/html/image\n\
chmod -R 775 /var/www/html/image\n\
\n\
# Pre-create config files to satisfy Apache\n\
[ ! -f /var/www/html/config.php ] && cp /var/www/html/config-dist.php /var/www/html/config.php || true\n\
[ ! -f /var/www/html/admin/config.php ] && cp /var/www/html/admin/config-dist.php /var/www/html/admin/config.php || true\n\
chown www-data:www-data /var/www/html/*.php /var/www/html/admin/*.php\n\
\n\
# MAP VARIABLE ENVIRONMENT ALTERNATIVES\n\
TARGET_HOST="${DB_HOSTNAME:-$DB_HOST}"\n\
TARGET_USER="${DB_USERNAME:-$DB_USER}"\n\
TARGET_PASS="${DB_PASSWORD:-$DB_PASS}"\n\
TARGET_NAME="${DB_DATABASE:-$DB_NAME}"\n\
\n\
# Run background installer safely\n\
if [ -d /var/www/html/install ] && [ ! -z "${TARGET_HOST}" ]; then\n\
  echo "Attempting silent OpenCart installation onto host: ${TARGET_HOST}"\n\
  php /var/www/html/install/cli_install.php install \\\n\
    --db_driver mysqli \\\n\
    --db_hostname "${TARGET_HOST}" \\\n\
    --db_username "${TARGET_USER:-admin}" \\\n\
    --db_password "${TARGET_PASS}" \\\n\
    --db_database "${TARGET_NAME:-opencartshop}" \\\n\
    --db_port 3306 \\\n\
    --db_prefix oc_ \\\n\
    --username "${OC_ADMIN_USER:-admin}" \\\n\
    --password "${OC_ADMIN_PASSWORD:-AdminPass123!}" \\\n\
    --email "${OC_ADMIN_EMAIL:-admin@example.com}" \\\n\
    --http_server "http://localhost/" || echo "CRITICAL WIZARD WARNING: DB setup failed, but keeping container alive for diagnostics."\n\
else\n\
  echo "WIZARD WARNING: Skipping background install because TARGET_HOST environment variable is missing or empty."\n\
fi\n\
\n\
echo "Starting Apache web server..."\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

# 4. Make it executable and set it
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
