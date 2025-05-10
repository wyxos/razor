#!/bin/bash
cd /var/www/razor || exit 1
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
chown -R www-data:www-data .
systemctl reload php8.2-fpm
