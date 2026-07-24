# 1. Use the verified, available stable release tag
FROM aamservices/opencart:3.0.3.8

# 2. Inject production PHP settings
RUN echo "display_errors = Off;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "upload_max_filesize = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "post_max_size = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini

# 3. Secure file permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# 4. Entrypoint that generates operational configs without using the CLI wizard
RUN printf '#!/bin/bash\n\
set -e\n\
\n\
# Force correct directory structures\n\
mkdir -p /var/www/html/image/cache/\n\
mkdir -p /var/www/html/image/catalog/\n\
chown -R www-data:www-data /var/www/html/image\n\
chmod -R 775 /var/www/html/image\n\
\n\
# Clean clean environment variables\n\
HOST_ONLY=$(echo "${DB_HOSTNAME:-$DB_HOST}" | sed "s/^.*@//")\n\
USER_ONLY="${DB_USERNAME:-$DB_USER}"\n\
PASS_ONLY="${DB_PASSWORD:-$DB_PASS}"\n\
NAME_ONLY="${DB_DATABASE:-$DB_NAME}"\n\
\n\
echo "Writing configuration specs for DB Host: $HOST_ONLY"\n\
\n\
# Build root config.php dynamically\n\
cat <<EOF > /var/www/html/config.php\n\
<?php\n\
define(\x27HTTP_SERVER\x27, \x27http://localhost/\x27);\n\
define(\x27HTTPS_SERVER\x27, \x27http://localhost/\x27);\n\
define(\x27DIR_APPLICATION\x27, \x27/var/www/html/catalog/\x27);\n\
define(\x27DIR_SYSTEM\x27, \x27/var/www/html/system/\x27);\n\
define(\x27DIR_IMAGE\x27, \x27/var/www/html/image/\x27);\n\
define(\x27DIR_STORAGE\x27, \x27/var/www/system/storage/\x27);\n\
define(\x27DIR_LANGUAGE\x27, \x27/var/www/html/catalog/language/\x27);\n\
define(\x27DIR_TEMPLATE\x27, \x27/var/www/html/catalog/view/theme/\x27);\n\
define(\x27DIR_CONFIG\x27, \x27/var/www/html/system/config/\x27);\n\
define(\x27DIR_CACHE\x27, \x27/var/www/system/storage/cache/\x27);\n\
define(\x27DIR_DOWNLOAD\x27, \x27/var/www/system/storage/download/\x27);\n\
define(\x27DIR_LOGS\x27, \x27/var/www/system/storage/logs/\x27);\n\
define(\x27DIR_MODIFICATION\x27, \x27/var/www/system/storage/modification/\x27);\n\
define(\x27DIR_UPLOAD\x27, \x27/var/www/system/storage/upload/\x27);\n\
define(\x27DB_DRIVER\x27, \x27mysqli\x27);\n\
define(\x27DB_HOSTNAME\x27, \x27\x27 . \$HOST_ONLY . \x27\x27);\n\
define(\x27DB_USERNAME\x27, \x27\x27 . \$USER_ONLY . \x27\x27);\n\
define(\x27DB_PASSWORD\x27, \x27\x27 . \$PASS_ONLY . \x27\x27);\n\
define(\x27DB_DATABASE\x27, \x27\x27 . \$NAME_ONLY . \x27\x27);\n\
define(\x27DB_PORT\x27, \x273306\x27);\n\
define(\x27DB_PREFIX\x27, \x27oc_\x27);\n\
EOF\n\
\n\
# Build admin config.php dynamically\n\
cat <<EOF > /var/www/html/admin/config.php\n\
<?php\n\
define(\x27HTTP_SERVER\x27, \x27http://localhost/admin/\x27);\n\
define(\x27HTTP_CATALOG\x27, \x27http://localhost/\x27);\n\
define(\x27HTTPS_SERVER\x27, \x27http://localhost/admin/\x27);\n\
define(\x27HTTPS_CATALOG\x27, \x27http://localhost/\x27);\n\
define(\x27DIR_APPLICATION\x27, \x27/var/www/html/admin/\x27);\n\
define(\x27DIR_SYSTEM\x27, \x27/var/www/html/system/\x27);\n\
define(\x27DIR_IMAGE\x27, \x27/var/www/html/image/\x27);\n\
define(\x27DIR_STORAGE\x27, \x27/var/www/system/storage/\x27);\n\
define(\x27DIR_LANGUAGE\x27, \x27/var/www/html/admin/language/\x27);\n\
define(\x27DIR_TEMPLATE\x27, \x27/var/www/html/admin/view/template/\x27);\n\
define(\x27DIR_CONFIG\x27, \x27/var/www/html/system/config/\x27);\n\
define(\x27DIR_CACHE\x27, \x27/var/www/system/storage/cache/\x27);\n\
define(\x27DIR_DOWNLOAD\x27, \x27/var/www/system/storage/download/\x27);\n\
define(\x27DIR_LOGS\x27, \x27/var/www/system/storage/logs/\x27);\n\
define(\x27DIR_MODIFICATION\x27, \x27/var/www/system/storage/modification/\x27);\n\
define(\x27DIR_UPLOAD\x27, \x27/var/www/system/storage/upload/\x27);\n\
define(\x27DIR_CATALOG\x27, \x27/var/www/html/catalog/\x27);\n\
define(\x27DB_DRIVER\x27, \x27mysqli\x27);\n\
define(\x27DB_HOSTNAME\x27, \x27\x27 . \$HOST_ONLY . \x27\x27);\n\
define(\x27DB_USERNAME\x27, \x27\x27 . \$USER_ONLY . \x27\x27);\n\
define(\x27DB_PASSWORD\x27, \x27\x27 . \$PASS_ONLY . \x27\x27);\n\
define(\x27DB_DATABASE\x27, \x27\x27 . \$NAME_ONLY . \x27\x27);\n\
define(\x27DB_PORT\x27, \x273306\x27);\n\
define(\x27DB_PREFIX\x27, \x27oc_\x27);\n\
EOF\n\
\n\
chown www-data:www-data /var/www/html/config.php /var/www/html/admin/config.php\n\
chmod 644 /var/www/html/config.php /var/www/html/admin/config.php\n\
\n\
# Securely drop the installation wizard folder entirely\n\
rm -rf /var/www/html/install\n\
\n\
echo "Configuration injected. Launching Apache..."\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

# 5. Make it executable and run it
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
