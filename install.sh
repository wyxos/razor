#!/bin/bash

set -e

echo "🛠  Installing Razor Server Panel..."

# Ensure the system is up to date
apt update && apt upgrade -y

# Install base dependencies
apt install -y git unzip curl php-cli php-mbstring php-xml php-bcmath php-curl php-mysql php-zip php-fpm php-gd php-soap php-tokenizer nginx mariadb-server supervisor ufw

# Create razor user if not exists
if ! id "razor" &>/dev/null; then
  adduser --disabled-password --gecos "" razor
fi

# Set up app directory
APP_DIR="/home/razor/razor"
mkdir -p "$APP_DIR"
chown razor:razor "$APP_DIR"

# Set up database
echo "📂 Creating database..."
DB_NAME="razor"
DB_USER="razor"
DB_PASS="razorpass"

mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mariadb -e "FLUSH PRIVILEGES;"

# Clone Razor panel
echo "📦 Cloning Razor..."
sudo -u razor git clone git@github.com:wyxos/razor.git "$APP_DIR" || { echo "Clone failed, aborting."; exit 1; }

cd "$APP_DIR"

# Set permissions
chown -R www-data:www-data .

# Install PHP dependencies
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-dev --optimize-autoloader

# .env setup
cp .env.example .env
php artisan key:generate
php artisan migrate --force

# NGINX config
echo "🌐 Configuring NGINX..."
cat >/etc/nginx/sites-available/razor <<EOF
server {
    listen 80;
    server_name _;

    root /home/razor/razor/public;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.2-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/razor /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Firewall (optional)
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw --force enable

echo "✅ Razor installed. Visit your server IP in the browser to access it."
