FROM php:8.2-fpm

# Installe les outils système et les librairies pour Postgres/Images
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd

# Installe Composer (le gestionnaire de paquets PHP)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Dossier de travail
WORKDIR /var/www/html

# On copie tout le projet
COPY . .

# On donne les droits d'écriture à Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Port exposé
EXPOSE 8001

# Commande de démarrage : lance le serveur de dev sur le port 8001
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8001"]
