#!/bin/bash

set -e

echo "🛠  Installing Razor Server Panel..."

# Ensure the system is up to date
apt update && apt upgrade -y

# Install base dependencies (MariaDB excluded)
apt install -y git unzip curl php-cli php-mbstring php-xml php-bcmath php-curl php-zip php-fpm php-gd php-soap php-tokenizer php-sqlite3 nginx supervisor ufw

# Create razor user if not exists
if ! id "razor" &>/dev/null; then
  adduser --disabled-password --gecos "" razor
fi

# Set up app directory
APP_DIR="/home/razor/razor"
if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
  read -p "⚠️  $APP_DIR already exists and is not empty. Overwrite? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted by user."
    exit 1
  fi
  rm -rf "$APP_DIR"
fi

mkdir -p "$APP_DIR"
chown razor:razor "$APP_DIR"

# Clone Razor panel
echo "📦 Cloning Razor..."
git clone https://github.com/wyxos/razor.git "$APP_DIR" || { echo "Clone failed, aborting."; exit 1; }

cd "$APP_DIR"

# Set permissions
chown -R www-data:www-data .
chmod o+rx /home/razor
chmod -R o+rw /home/razor/razor/storage /home/razor/razor/bootstrap/cache

# Install PHP dependencies
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-dev --optimize-autoloader

# .env setup
cp .env.example .env
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE=/home/razor/razor/database/database.sqlite|' .env

# Ensure SQLite file exists
touch /home/razor/razor/database/database.sqlite
chown www-data:www-data /home/razor/razor/database/database.sqlite
chmod 664 /home/razor/razor/database/database.sqlite
chmod o+rx /home/razor/razor/database

php artisan key:generate
php artisan migrate --force

# Install Node.js via NVM and build frontend
export NVM_DIR="/home/razor/.nvm"
mkdir -p "$NVM_DIR"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

export NVM_DIR="/home/razor/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts

cd /home/razor/razor
npm ci || npm install
npm run build

# NGINX config
echo "🌐 Configuring NGINX..."
cat >/etc/nginx/sites-available/razor <<EOF
server {
    listen 80;
    server_name _;

    root /home/razor/razor/public;
    index index.php index.html;

    location / {
        try_files \$uri /index.php?\$query_string;
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
