FROM php:7.4.1-cli-alpine

RUN apk --update add \
        postgresql-dev \
        oniguruma-dev && \
    docker-php-ext-install \
        mbstring \
        opcache \
        pdo_pgsql && \
    apk del \
        gcc \
        g++

# Configure version constraints
ENV VERSION_PRESTISSIMO_PLUGIN=^0.3.9 \
    COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer global require --optimize-autoloader \
        "hirak/prestissimo:${VERSION_PRESTISSIMO_PLUGIN}" && \
    composer global dumpautoload --optimize

# xdebug
ENV XDEBUG_VERSION 2.9.0
RUN apk --no-cache add --virtual .build-deps \
        g++ \
        autoconf \
        make && \
    pecl install xdebug-$XDEBUG_VERSION && \
    docker-php-ext-enable xdebug && \
    apk del .build-deps && \
    rm -r /tmp/pear/* && \
    mkdir -p /var/log/bot && \
    touch /var/log/bot/xdebug.log

WORKDIR /var/www
RUN rm -rf ./* && \
    addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser && \
    chown -R appuser:appuser .
USER appuser

ADD composer.* /var/www/
RUN composer install --prefer-dist

COPY . /var/www/
