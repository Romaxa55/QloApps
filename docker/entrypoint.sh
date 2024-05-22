#!/bin/sh

# Set timezone
if [ -n "$timezone" ]; then
    echo "date.timezone = $timezone" >> /etc/php$php_version/php.ini
fi

# Start PHP-FPM
php-fpm$php_version

# Start Nginx
exec "$@"
