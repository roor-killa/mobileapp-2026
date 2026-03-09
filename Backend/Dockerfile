# ─── Base Image ───────────────────────────────────────────────────────────────
FROM php:8.2-fpm

# ─── Arguments ────────────────────────────────────────────────────────────────
ARG user=www
ARG uid=1000

# ─── Dépendances système ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    libzip-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ─── Extensions PHP ───────────────────────────────────────────────────────────
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# ─── Extension Redis (PECL) ───────────────────────────────────────────────────
RUN pecl install redis \
    && docker-php-ext-enable redis

# ─── Composer ─────────────────────────────────────────────────────────────────
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# ─── Utilisateur non-root ─────────────────────────────────────────────────────
RUN useradd -G www-data,root -u $uid -d /home/$user $user \
    && mkdir -p /home/$user/.composer \
    && chown -R $user:$user /home/$user

# ─── Répertoire de travail ────────────────────────────────────────────────────
WORKDIR /var/www

# ─── Entrypoint ───────────────────────────────────────────────────────────────
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER $user

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
