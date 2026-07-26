FROM aamservices/opencart:4.0.0.0

ENV OPENCART_DEBUG=0

COPY upload/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
