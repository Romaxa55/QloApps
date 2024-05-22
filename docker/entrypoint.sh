#!/bin/sh
set -e

# Set the timezone
ln -snf /usr/share/zoneinfo/$timezone /etc/localtime
echo $timezone > /etc/timezone

# Create necessary directories
mkdir -p /var/run/php/
chown -R qloapps:qloapps /var/run/php/

# Create necessary directories for Nginx
mkdir -p /var/lib/nginx/logs
mkdir -p /var/lib/nginx/tmp/client_body
chown -R qloapps:qloapps /var/lib/nginx

# Run Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
