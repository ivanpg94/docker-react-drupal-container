FROM php:8.2-apache-buster

# Instalar las extensiones necesarias para Drupal
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN apt-get update && apt-get install -y \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libwebp-dev \
        libzip-dev \
        libpq-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_pgsql zip

# Instalar Node.js y npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Habilitar mod_rewrite para Apache
RUN a2enmod rewrite

# Configurar la raíz del documento
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

# Copiar el código fuente de Drupal
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html

# Verificar si Drupal ya está instalado
RUN if [ ! -f /var/www/html/core/lib/Drupal.php ]; then \
    composer create-project drupal/recommended-project:10.2.6 .; \
    chown -R www-data:www-data /var/www/html; \
    chmod -R 755 /var/www/html; \
    fi

# Asignar permisos adecuados
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Instalar y habilitar Xdebug
#RUN pecl install xdebug \
#    && docker-php-ext-enable xdebug \
#    && echo "zend_extension=xdebug" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#    && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#    && echo "xdebug.client_host=172.80.25.4" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#    && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#    && echo "xdebug.log=/tmp/xdebug.log" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
#    && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Ajustar la configuración de PHP
RUN echo "memory_limit = 1024M" > /usr/local/etc/php/conf.d/memory-limit.ini

EXPOSE 80
