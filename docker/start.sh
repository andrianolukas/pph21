#!/bin/bash
set -e

# Use Render's PORT or default to 8080
PORT="${PORT:-8080}"

# Update nginx to listen on the correct port
sed -i "s/listen 8080/listen $PORT/" /etc/nginx/sites-available/default

# Run Laravel optimizations (config needs env vars from Render)
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
php artisan migrate --force --no-interaction

# Fix permissions
chown -R www-data:www-data storage bootstrap/cache

# Start php-fpm in background
php-fpm -D

# Start nginx in foreground (keeps container running, handles signals properly)
nginx -g 'daemon off;'
