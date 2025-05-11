#!/bin/bash

set -e

echo "🛠  Installing Razor Server Panel..."

# Update and base packages
apt update && apt upgrade -y
apt install -y git unzip curl software-properties-common nginx supervisor ufw

# Add ondrej/php PPA
add-apt-repository ppa:ondrej/php -y
apt update

# Install PHP versions 8.0–8.4
PHP_VERSIONS=("8.0" "8.1" "8.2" "8.3" "8.4")
for ver in "${PHP_VERSIONS[@]}"; do
  apt install -y php$ver-cli php$ver-fpm php$ver-mbstring php$ver-xml php$ver-bcmath php$ver-curl php$ver-zip php$ver-gd php$ver-soap php$ver-tokenizer php$ver-sqlite3

  mkdir -p /opt/php/$ver/bin
  cp -L /usr/bin/php$ver /opt/php/$ver/bin/php
  ln -sf /opt/php/$ver/bin/php /usr/bin/php${ver//./}

  curl -sS https://getcomposer.org/installer | /opt/php/$ver/bin/php -- --install-dir=/opt/php/$ver/bin --filename=composer
  ln -sf /opt/php/$ver/bin/composer /usr/bin/composer${ver//./}
done

# Create razor user if not exists
if ! id "razor" &>/dev/null; then
  adduser --disabled-password --gecos "" razor
fi

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

echo "📦 Cloning Razor..."
git clone https://github.com/wyxos/razor.git "$APP_DIR" || { echo "Clone failed, aborting."; exit 1; }

cd "$APP_DIR"

chown -R www-data:www-data .
chmod o+rx /home/razor
chmod -R o+rw storage bootstrap/cache

cp .env.example .env
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE=/home/razor/razor/database/database.sqlite|' .env

touch database/database.sqlite
chown www-data:www-data database/database.sqlite
chmod 664 database/database.sqlite
chmod o+rx database

php84 /usr/bin/composer84 install --no-dev --optimize-autoloader
php84 artisan key:generate
php84 artisan migrate --force

# Install Node.js via NVM and build frontend
export NVM_DIR="/home/razor/.nvm"
mkdir -p "$NVM_DIR"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts

npm ci || npm install
npm run build

# Configure NGINX
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
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/razor /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
systemctl restart nginx

# Enable firewall
ufw allow OpenSSH
ufw allow "Nginx Full"
ufw --force enable

echo "✅ Razor installed. Visit your server IP in the browser to access it."
