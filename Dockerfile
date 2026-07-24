FROM aamservices/opencart:3.0.3.8

# 1. Inject production PHP settings and direct stderr logs
RUN echo "display_errors = On;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "log_errors = On;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_log = /dev/stderr;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "upload_max_filesize = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini && \
    echo "post_max_size = 64M;" >> /usr/local/etc/php/conf.d/opencart.ini

# 2. Pre-bake the Root config.php template
RUN echo '<?php\n\
define("HTTP_SERVER", "http://localhost/");\n\
define("HTTPS_SERVER", "http://localhost/");\n\
define("DIR_APPLICATION", "/var/www/html/catalog/");\n\
define("DIR_SYSTEM", "/var/www/html/system/");\n\
define("DIR_IMAGE", "/var/www/html/image/");\n\
define("DIR_STORAGE", "/var/www/html/storage/");\n\
define("DIR_LANGUAGE", "/var/www/html/catalog/language/");\n\
define("DIR_TEMPLATE", "/var/www/html/catalog/view/theme/");\n\
define("DIR_CONFIG", "/var/www/html/system/config/");\n\
define("DIR_CACHE", "/var/www/html/storage/cache/");\n\
define("DIR_DOWNLOAD", "/var/www/html/storage/download/");\n\
define("DIR_LOGS", "/var/www/html/storage/logs/");\n\
define("DIR_MODIFICATION", "/var/www/html/storage/modification/");\n\
define("DIR_UPLOAD", "/var/www/html/storage/upload/");\n\
define("DB_DRIVER", "mysqli");\n\
define("DB_HOSTNAME", preg_replace("/^.*@/", "", getenv("DB_HOSTNAME") ?: getenv("DB_HOST")));\n\
define("DB_USERNAME", getenv("DB_USERNAME") ?: getenv("DB_USER"));\n\
define("DB_PASSWORD", getenv("DB_PASSWORD") ?: getenv("DB_PASS"));\n\
define("DB_DATABASE", getenv("DB_DATABASE") ?: getenv("DB_NAME"));\n\
define("DB_PORT", "3306");\n\
define("DB_PREFIX", "oc_");' > /var/www/html/config.php

# 3. Pre-bake the Admin config.php template
RUN echo '<?php\n\
define("HTTP_SERVER", "http://localhost/admin/");\n\
define("HTTP_CATALOG", "http://localhost/");\n\
define("HTTPS_SERVER", "http://localhost/admin/");\n\
define("HTTPS_CATALOG", "http://localhost/");\n\
define("DIR_APPLICATION", "/var/www/html/admin/");\n\
define("DIR_SYSTEM", "/var/www/html/system/");\n\
define("DIR_IMAGE", "/var/www/html/image/");\n\
define("DIR_STORAGE", "/var/www/html/storage/");\n\
define("DIR_LANGUAGE", "/var/www/html/admin/language/");\n\
define("DIR_TEMPLATE", "/var/www/html/admin/view/template/");\n\
define("DIR_CONFIG", "/var/www/html/system/config/");\n\
define("DIR_CACHE", "/var/www/html/storage/cache/");\n\
define("DIR_DOWNLOAD", "/var/www/html/storage/download/");\n\
define("DIR_LOGS", "/var/www/html/storage/logs/");\n\
define("DIR_MODIFICATION", "/var/www/html/storage/modification/");\n\
define("DIR_UPLOAD", "/var/www/html/storage/upload/");\n\
define("DIR_CATALOG", "/var/www/html/catalog/");\n\
define("DB_DRIVER", "mysqli");\n\
define("DB_HOSTNAME", preg_replace("/^.*@/", "", getenv("DB_HOSTNAME") ?: getenv("DB_HOST")));\n\
define("DB_USERNAME", getenv("DB_USERNAME") ?: getenv("DB_USER"));\n\
define("DB_PASSWORD", getenv("DB_PASSWORD") ?: getenv("DB_PASS"));\n\
define("DB_DATABASE", getenv("DB_DATABASE") ?: getenv("DB_NAME"));\n\
define("DB_PORT", "3306");\n\
define("DB_PREFIX", "oc_");' > /var/www/html/admin/config.php

# 4. Standard file permissions and wipe out installer layout folder
RUN rm -rf /var/www/html/install && \
    chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# 5. Clean runtime entrypoint to force persistent image directory configurations
RUN printf '#!/bin/bash\n\
set -e\n\
mkdir -p /var/www/html/image/cache/ /var/www/html/image/catalog/\n\
mkdir -p /var/www/html/storage/cache/ /var/www/html/storage/download/ /var/www/html/storage/logs/ /var/www/html/storage/modification/ /var/www/html/storage/upload/\n\
chown -R www-data:www-data /var/www/html/image /var/www/html/storage\n\
chmod -R 775 /var/www/html/image /var/www/html/storage\n\
echo "Configurations successfully mounted. Booting Apache..."\n\
exec docker-php-entrypoint apache2-foreground\n' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
