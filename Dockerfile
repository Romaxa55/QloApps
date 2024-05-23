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
    max_input_vars=1500 \
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
    -e 's/memory_limit = .*/memory_limit = '${memory_limit}'/' \
    -e 's/file_uploads = .*/file_uploads = '${file_uploads}'/' \
    -e 's/allow_url_fopen = .*/allow_url_fopen = '${allow_url_fopen}'/' \
    -e 's/max_execution_time = .*/max_execution_time = '${max_execution_time}'/' \
    -e 's/upload_max_filesize = .*/upload_max_filesize = '${upload_max_filesize}'/' \
    -e 's/post_max_size = .*/post_max_size = '${post_max_size}'/' \
    -e 's/max_input_vars = .*/max_input_vars = '${max_input_vars}'/' \
    -e 's|;*error_log =.*|error_log = /proc/self/fd/2|' /etc/php$php_version/php.ini \
    -e 's|;*access.log =.*|access.log = /proc/self/fd/2|' /etc/php$php_version/php-fpm.conf \
    -e 's|display_errors = Off|display_errors = On|' /etc/php$php_version/php.ini \
    -e 's|display_startup_errors = Off|display_startup_errors = On|' /etc/php$php_version/php.ini \
    -e 's|log_errors = Off|log_errors = On|' /etc/php$php_version/php.ini \
    -e 's|error_reporting = .*|error_reporting = E_ALL|' /etc/php$php_version/php.ini \
    -e 's|error_log = /proc/self/fd/2|error_log = /var/log/php_errors.log|' /etc/php$php_version/php.ini \
    -e 's|sys_temp_dir = "/tmp"|sys_temp_dir = "/tmp/qloapps"|' /etc/php$php_version/php.ini \
    -e 's|upload_tmp_dir = "/tmp"|upload_tmp_dir = "/tmp/qloapps"|' /etc/php$php_version/php.ini \
    -e 's|session.save_path = "/tmp"|session.save_path = "/tmp/qloapps"|' /etc/php$php_version/php.ini \
    -e 's|listen = 127.0.0.1:9000|listen = /var/run/php/php-fpm.sock|' /etc/php$php_version/php-fpm.d/www.conf \
    -e 's|;listen.owner = nobody|listen.owner = '${user}'|' /etc/php$php_version/php-fpm.d/www.conf \
    -e 's|;listen.group = nobody|listen.group = '${user}'|' /etc/php$php_version/php-fpm.d/www.conf \
    -e 's|;listen.mode = 0660|listen.mode = 0660|' /etc/php$php_version/php-fpm.d/www.conf \
    -e 's|;catch_workers_output = no|catch_workers_output = yes|' /etc/php$php_version/php-fpm.d/www.conf

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
