FROM aamservices/opencart:3.0.3.8

# 1. Force PHP to log errors directly to Docker stdout
RUN echo "display_errors = On;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "log_errors = On;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_log = /dev/stderr;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "upload_max_filesize = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "post_max_size = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini

# 2. Secure file permissions
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# 3. Create entrypoint script using safe single-quoted EOF blocks
RUN printf '#!/bin/bash\n\
set -e\n\
\n\
# Ensure standard folders exist\n\
mkdir -p /var/www/html/image/cache/\n\
mkdir -p /var/www/html/image/catalog/\n\
mkdir -p /var/www/html/storage/cache/\n\
mkdir -p /var/www/html/storage/download/\n\
mkdir -p /var/www/html/storage/logs/\n\
mkdir -p /var/www/html/storage/modification/\n\
mkdir -p /var/www/html/storage/upload/\n\
chown -R www-data:www-data /var/www/html/image /var/www/html/storage\n\
chmod -R 775 /var/www/html/image /var/www/html/storage\n\
\n\
# Sanitize variables\n\
export HOST_ONLY=$(echo "${DB_HOSTNAME:-$DB_HOST}" | sed "s/^.*@//")\n\
export USER_ONLY="${DB_USERNAME:-$DB_USER}"\n\
export PASS_ONLY="${DB_PASSWORD:-$DB_PASS}"\n\
export NAME_ONLY="${DB_DATABASE:-$DB_NAME}"\n\
\n\
echo "Generating production configuration..."\n\
\n\
# Corrected Root config.php mapping using environmental substitution\n\
cat << \x27EOF\x27 > /var/www/html/config.php\n\
<?php\n\
define(\x27HTTP_SERVER\x27, \x27http://localhost/\x27);\n\
define(\x27HTTPS_SERVER\x27, \x27http://localhost/\x27);\n\
define(\x27DIR_APPLICATION\x27, \x27/var/www/html/catalog/\x27);\n\
define(\x27DIR_SYSTEM\x27, \x27/var/www/html/system/\x27);\n\
define(\x27DIR_IMAGE\x27, \x27/var/www/html/image/\x27);\n\
define(\x27DIR_STORAGE\x27, \x27/var/www/html/storage/\x27);\n\
define(\x27DIR_LANGUAGE\x27, \x27/var/www/html/catalog/language/\x27);\n\
define(\x27DIR_TEMPLATE\x27, \x27/var/www/html/catalog/view/theme/\x27);\n\
define(\x27DIR_CONFIG\x27, \x27/var/www/html/system/config/\x27);\n\
define(\x27DIR_CACHE\x27, \x27/var/www/html/storage/cache/\x27);\n\
define(\x27DIR_DOWNLOAD\x27, \x27/var/www/html/storage/download/\x27);\n\
define(\x27DIR_LOGS\x27, \x27/var/www/html/storage/logs/\x27);\n\
define(\x27DIR_MODIFICATION\x27, \x27/var/www/html/storage/modification/\x27);\n\
define(\x27DIR_UPLOAD\x27, \x27/var/www/html/storage/upload/\x27);\n\
define(\x27DB_DRIVER\x27, \x27mysqli\x27);\n\
define(\x27DB_HOSTNAME\x27, getenv(\x27HOST_ONLY\x27));\n\
define(\x27DB_USERNAME\x27, getenv(\x27USER_ONLY\x27));\n\
define(\x27DB_PASSWORD\x27, getenv(\x27PASS_ONLY\x27));\n\
define(\x27DB_DATABASE\x27, getenv(\x27NAME_ONLY\x27));\n\
define(\x27DB_PORT\x27, \x273306\x27);\n\
define(\x27DB_PREFIX\x27, \x27oc_\x27);\n\
EOF\n\
\n\
# Corrected Admin config.php mapping using environmental substitution\n\
cat << \x27EOF\x27 > /var/www/html/admin/config.php\n\
<?php\n\
define(\x27HTTP_SERVER\x27, \x27http://localhost/admin/\x27);\n\
define(\x27HTTP_CATALOG\x27, \x27http://localhost/\x27);\n\
define(\x27HTTPS_SERVER\x27, \x27http://localhost/admin/\x27);\n\
define(\x27HTTPS_CATALOG\x27, \x27http://localhost/\x27);\n\
define(\x27DIR_APPLICATION\x27, \x27/var/www/html/admin/\x27);\n\
define(\x27DIR_SYSTEM\x27, \x27/var/www/html/system/\x27);\n\
define(\x27DIR_IMAGE\x27, \x27/var/www/html/image/\x27);\n\
define(\x27DIR_STORAGE\x27, \x27/var/www/html/storage/\x27);\n\
define(\x27DIR_LANGUAGE\x27, \x27/var/www/html/admin/language/\x27);\n\
define(\x27DIR_TEMPLATE\x27, \x27/var/www/html/admin/view/template/\x27);\n\
define(\x27DIR_CONFIG\x27, \x27/var/www/html/system/config/\x27);\n\
define(\x27DIR_CACHE\x27, \x27/var/www/html/storage/cache/\x27);\n\
define(\x27DIR_DOWNLOAD\x27, \x27/var/www/html/storage/download/\x27);\n\
define(\x27DIR_LOGS\x27, \x27/var/www/html/storage/logs/\x27);\n\
define(\x27DIR_MODIFICATION\x27, \x27/var/www/html/storage/modification/\x27);\n\
define(\x27DIR_UPLOAD\x27, \x27/var/www/html/storage/upload/\x27);\n\
define(\x27DIR_CATALOG\x27, \x27/var/www/html/catalog/\x27);\n\
define(\x27DB_DRIVER\x27, \x27mysqli\x27);\n\
define(\x27DB_HOSTNAME\x27, getenv(\x27HOST_ONLY\x27));\n\
define(\x27DB_USERNAME\x27, getenv(\x27USER_ONLY\x27));\n\
define(\x27DB_PASSWORD\x27, getenv(\x27PASS_ONLY\x27));\n\
define(\x27DB_DATABASE\x27, getenv(\x27NAME_ONLY\x27));\n\
define(\x27DB_PORT\x27, \x273306\x27);\n\
define(\x27DB_PREFIX\x27, \x27oc_\x27);\n\
EOF\n\
\n\
chown www-data:www-data /var/www/html/config.php /var/www/html/admin/config.php\n\
chmod 644 /var/www/html/config.php /var/www/html/admin/config.php\n\
\n\
# Remove installer UI folder\n\
rm -rf /var/www/html/install\n\
\n\
echo "Launching production server..."\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
