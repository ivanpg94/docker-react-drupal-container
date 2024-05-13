FROM php:8.2-apache-buster

# Instalar las extensiones necesarias para Drupal

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/*
RUN apt-get update && apt-get install -y \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libwebp-dev \
        libmcrypt-dev \
        libzip-dev \
        mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install pdo pdo_mysql zip

# Habilitar mod_rewrite para Apache
RUN a2enmod rewrite

# Configurar la raíz del documento
ENV APACHE_DOCUMENT_ROOT /var/www/html/web

# Copiar el código fuente de Drupal
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
RUN composer create-project drupal/recommended-project:10.2.6 .

# Asignar permisos adecuados
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE 80
