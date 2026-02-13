# backend/Dockerfile
FROM php:8.2-cli

# Installation des dépendances système et extensions PHP requises (Postgres + Zip)
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql

# Installation de Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Répertoire de travail
WORKDIR /var/www

# Commande par défaut : lance le serveur de développement Laravel sur toutes les interfaces
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
