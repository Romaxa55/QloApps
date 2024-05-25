#!/bin/sh
set -e

# Create necessary directories for PHP
mkdir -p /var/run/php/
chown -R qloapps:qloapps /var/run/php/

# Create necessary directories for Nginx
mkdir -p /var/lib/nginx/logs
mkdir -p /var/lib/nginx/tmp/client_body
chown -R qloapps:qloapps /var/lib/nginx

# Create necessary directories for the application and set permissions
for dir in config cache log img mails modules themes/hotel-reservation-theme/lang themes/hotel-reservation-theme/pdf/lang themes/hotel-reservation-theme/cache translations upload download; do
    mkdir -p /home/qloapps/$dir
    chown -R qloapps:qloapps /home/qloapps/$dir
    chmod -R 777 /home/qloapps/$dir
done

# Install Composer dependencies in development environment
if [ "$ENVIRONMENT" = "development" ]; then
    echo "Running composer install..."
    composer install --prefer-dist --optimize-autoloader --no-interaction
fi

# Run Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
