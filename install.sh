#!/bin/bash

set -e

echo "🛠  Installing Razor Server Panel..."

# Ensure the system is up to date
apt update && apt upgrade -y

# Install base dependencies
apt install -y git unzip curl php-cli php-mbstring php-xml php-bcmath php-curl php-mysql php-zip php-fpm php-gd php-soap php-tokenizer nginx mysql-server supervisor ufw

# Set up database
echo "💾 Creating database..."
DB_NAME="razor"
DB_USER="razor"
DB_PASS="razorpass"

mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Clone Razor panel
echo "📦 Cloning Razor..."
git clone https://github.com/YOUR_USERNAME/razor /var/www/razor

cd /var/www/razor

# Set permissions
chown -R www-data:www-data .

# Install PHP dependencies
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-dev --optimize-autoloader

# .env setup (basic stub)
cp .env.example .env
php artisan key:generate
php artisan migrate --force

# NGINX config
echo "🌐 Configuring NGINX..."
cat >/etc/nginx/sites-available/razor <<EOF
server {
    listen 80;
    server_name _;
    root /var/www/razor/public;

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

ln -s /etc/nginx/sites-available/razor /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
systemctl restart nginx

# Firewall (optional)
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw --force enable

echo "✅ Razor installed. Visit your server IP in the browser to access it."
