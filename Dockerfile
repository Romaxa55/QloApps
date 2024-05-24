FROM alpine:3.15
LABEL maintainer="Roman Shamagin"

ARG user=qloapps

# Php file configuration with php version and mysql version
ENV php_version=7 \
    file_uploads=On \
    allow_url_fopen=On \
    memory_limit=128M \
    max_execution_time=500 \
    upload_max_filesize=16M \
    post_max_size=400M \
    max_input_vars=5000 \
    timezone=Asia/Ho_Chi_Minh \
    TMPDIR=/tmp/qloapps \
    APACHE_RUN_USER=${user}

# Set working directory
WORKDIR /home/${user}

# Update server and install necessary packages
RUN apk update \
    && apk add --no-cache nginx \
    && apk add --no-cache php$php_version php$php_version-bcmath php$php_version-cli php$php_version-json php$php_version-curl php$php_version-fpm php$php_version-gd php$php_version-ldap php$php_version-mbstring php$php_version-pdo_mysql php$php_version-soap php$php_version-sqlite3 php$php_version-xml php$php_version-zip php$php_version-intl php$php_version-pecl-imagick php$php_version-session php$php_version-dom curl git nano vim wget php$php_version-phar php$php_version-simplexml php$php_version-ctype supervisor grep

# Setup non-root user with specified home directory
RUN adduser -D -s /bin/sh -h /home/${user} ${user}

# Create temporary directory
RUN mkdir -p /tmp/qloapps \
    && chown -R ${user}:${user} /tmp/qloapps

# Copy Qloapps project
COPY . .

# Change file permissions and ownership
RUN find . -type f -exec chmod 644 {} \; \
    && find . -type d -exec chmod 755 {} \; \
    && chown -R ${user}:${user} .

# Configure PHP for logging errors to stdout and listen on Unix socket
RUN sed -i \
    -e 's/^\s*;\?\s*memory_limit\s*=.*/memory_limit = '${memory_limit}'/' \
    -e 's/^\s*;\?\s*file_uploads\s*=.*/file_uploads = '${file_uploads}'/' \
    -e 's/^\s*;\?\s*allow_url_fopen\s*=.*/allow_url_fopen = '${allow_url_fopen}'/' \
    -e 's/^\s*;\?\s*max_execution_time\s*=.*/max_execution_time = '${max_execution_time}'/' \
    -e 's/^\s*;\?\s*upload_max_filesize\s*=.*/upload_max_filesize = '${upload_max_filesize}'/' \
    -e 's/^\s*;\?\s*post_max_size\s*=.*/post_max_size = '${post_max_size}'/' \
    -e 's/^\s*;\?\s*max_input_vars\s*=.*/max_input_vars = '${max_input_vars}'/' \
    -e 's|^\s*;\?\s*error_log\s*=.*|error_log = /proc/self/fd/2|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*access.log\s*=.*|access.log = /proc/self/fd/2|' /etc/php$php_version/php-fpm.conf \
    -e 's|^\s*;\?\s*display_errors\s*=.*|display_errors = On|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*display_startup_errors\s*=.*|display_startup_errors = On|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*log_errors\s*=.*|log_errors = On|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*error_reporting\s*=.*|error_reporting = E_ALL|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*error_log\s*=.*|error_log = /var/log/php_errors.log|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*sys_temp_dir\s*=.*|sys_temp_dir = "/tmp/qloapps"|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*upload_tmp_dir\s*=.*|upload_tmp_dir = "/tmp/qloapps"|' /etc/php$php_version/php.ini \
    -e 's|^\s*;\?\s*session.save_path\s*=.*|session.save_path = "/tmp/qloapps"|' /etc/php$php_version/php.ini

RUN sed -i \
    -e 's|^\s*;\?\s*listen\s*=.*|listen = /var/run/php/php-fpm.sock|' \
    -e 's|^\s*;\?\s*listen.owner\s*=.*|listen.owner = '${user}'|' \
    -e 's|^\s*;\?\s*listen.group\s*=.*|listen.group = '${user}'|' \
    -e 's|^\s*;\?\s*listen.mode\s*=.*|listen.mode = 0660|' \
    -e 's|^\s*;\?\s*catch_workers_output\s*=.*|catch_workers_output = yes|' \
    /etc/php$php_version/php-fpm.d/www.conf

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Composer dependencies including dev dependencies
RUN /usr/local/bin/composer install --prefer-dist --optimize-autoloader

# Nginx configuration
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/site.conf /etc/nginx/conf.d/default.conf
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create necessary directories for Nginx and PHP-FPM
RUN mkdir -p /var/run/php/ \
    && mkdir -p /var/lib/nginx/logs \
    && mkdir -p /var/lib/nginx/tmp/client_body \
    && chown -R ${user}:${user} /var/run/php/ \
    && chown -R ${user}:${user} /var/lib/nginx \
    && mkdir -p /var/log/php \
    && touch /var/log/php_errors.log \
    && chown -R ${user}:${user} /var/log/php

# Supervisor configuration
COPY docker/supervisord.conf /etc/supervisor/supervisord.conf

# Expose ports
EXPOSE 80

# Start Supervisor
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
