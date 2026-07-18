# 1. Use a verified public OpenCart image built with Apache and PHP
FROM aamservices/opencart:4.0.0.0

# 2. Prevent OpenCart from running in developer mode and optimize for production
ENV OPENCART_DEBUG=0

# 3. Custom assets (Commented out until folders are populated in GitHub)
# COPY ./themes/ /var/www/html/extension/opencart/catalog/view/theme/
# COPY ./modules/ /var/www/html/extension/opencart/admin/

# 4. Correct ownership so Apache can read and write to the application files smoothly
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# 5. OpenCart specific deployment trick for stateless high-availability environments:
# Automatically rename the config distribution files so the wizard runs offline right away
RUN cp /var/www/html/config-dist.php /var/www/html/config.php && \
    cp /var/www/html/admin/config-dist.php /var/www/html/admin/config.php && \
    chown www-data:www-data /var/www/html/config.php /var/www/html/admin/config.php
