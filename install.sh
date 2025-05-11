##!/bin/bash
#
#set -e
#
#PHP_VERSION="8.4.0"
#INSTALL_DIR="/opt/php/8.4"
#FPM_SOCKET="/run/php/php8.4-fpm.sock"
#
## Skip if already installed
#if [ -x "$INSTALL_DIR/bin/php" ]; then
#  read -p "⚠️  PHP $PHP_VERSION already installed. Reinstall? (y/N): " confirm
#  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
#    echo "➡️  Skipping PHP build."
#  else
#    rm -rf "$INSTALL_DIR"
#  fi
#fi
#
#if [ ! -x "$INSTALL_DIR/bin/php" ]; then
#  # Install build dependencies
#  apt update && apt install -y \
#    build-essential \
#    autoconf \
#    bison \
#    re2c \
#    libxml2-dev \
#    libsqlite3-dev \
#    libcurl4-openssl-dev \
#    libzip-dev \
#    libonig-dev \
#    libjpeg-dev \
#    libpng-dev \
#    libwebp-dev \
#    libfreetype6-dev \
#    libssl-dev \
#    pkg-config \
#    unzip \
#    wget \
#    git \
#    curl \
#    nginx \
#    supervisor \
#    ufw
#
#  # Create razor user if not exists
#  if ! id "razor" &>/dev/null; then
#    adduser --disabled-password --gecos "" razor
#  fi
#
#  # Create PHP install directory
#  mkdir -p $INSTALL_DIR
#  cd /usr/src
#
#  # Download PHP source
#  wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz
#  tar -xzf php-$PHP_VERSION.tar.gz
#  cd php-$PHP_VERSION
#
#  # Configure
#  ./configure \
#    --prefix=$INSTALL_DIR \
#    --with-config-file-path=$INSTALL_DIR/etc \
#    --with-config-file-scan-dir=$INSTALL_DIR/etc/conf.d \
#    --enable-fpm \
#    --with-fpm-user=www-data \
#    --with-fpm-group=www-data \
#    --enable-mbstring \
#    --with-curl \
#    --with-openssl \
#    --with-zlib \
#    --with-zip \
#    --with-sqlite3 \
#    --with-pdo-sqlite \
#    --enable-soap \
#    --enable-bcmath \
#    --with-jpeg \
#    --with-webp \
#    --with-freetype \
#    --enable-gd
#
#  echo "⏳ Building PHP..."
#  make -s -j$(nproc)
#  make -s install
#
#  # Add symlinks
#  ln -sf $INSTALL_DIR/bin/php /usr/bin/php84
#
#  # Install Composer
#  curl -sS https://getcomposer.org/installer | php84 -- --install-dir=$INSTALL_DIR/bin --filename=composer
#  ln -sf $INSTALL_DIR/bin/composer /usr/bin/composer84
#
#  # Cleanup
#  cd /usr/src
#  rm -rf php-$PHP_VERSION php-$PHP_VERSION.tar.gz
#
#  echo "✅ PHP $PHP_VERSION installed in $INSTALL_DIR"
#
#  # Configure PHP-FPM
#  mkdir -p $INSTALL_DIR/etc/php-fpm.d
#  cat > $INSTALL_DIR/etc/php-fpm.d/www.conf <<EOF
#[www]
#user = www-data
#group = www-data
#listen = $FPM_SOCKET
#listen.owner = www-data
#listen.group = www-data
#pm = dynamic
#pm.max_children = 5
#pm.start_servers = 2
#pm.min_spare_servers = 1
#pm.max_spare_servers = 3
#EOF
#
#  cat > $INSTALL_DIR/etc/php-fpm.conf <<EOF
#include=$INSTALL_DIR/etc/php-fpm.d/*.conf
#EOF
#
#  # Systemd service for php84-fpm
#  cat >/etc/systemd/system/php84-fpm.service <<EOF
#[Unit]
#Description=PHP 8.4 FPM
#After=network.target
#
#[Service]
#Type=simple
#ExecStart=$INSTALL_DIR/sbin/php-fpm --nodaemonize --fpm-config $INSTALL_DIR/etc/php-fpm.conf
#ExecReload=/bin/kill -USR2 $MAINPID
#Restart=always
#
#[Install]
#WantedBy=multi-user.target
#EOF
#
#  mkdir -p /run/php
#  systemctl daemon-reexec
#  systemctl daemon-reload
#  systemctl enable php84-fpm
#  systemctl start php84-fpm
#fi
#
## Clone Razor
#APP_DIR="/home/razor/razor"
#if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
#  read -p "⚠️  $APP_DIR already exists and is not empty. Overwrite? (y/N): " confirm
#  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
#    echo "Aborted by user."
#    exit 1
#  fi
#  rm -rf "$APP_DIR"
#fi
#
#mkdir -p "$APP_DIR"
#chown razor:razor "$APP_DIR"
#
#echo "📦 Cloning Razor..."
#git clone https://github.com/wyxos/razor.git "$APP_DIR" || { echo "Clone failed, aborting."; exit 1; }
#
#cd "$APP_DIR"
#
#chown -R www-data:www-data .
#chmod o+rx /home/razor
#chmod -R o+rw storage bootstrap/cache
#
#cp .env.example .env
#
#touch database/database.sqlite
#chown www-data:www-data database/database.sqlite
#chmod 664 database/database.sqlite
#chmod o+rx database
#
#php84 /usr/bin/composer84 install --no-dev --optimize-autoloader
#php84 artisan key:generate
#php84 artisan migrate --force
#
## Install Node.js via NVM and build frontend
#export NVM_DIR="/home/razor/.nvm"
#mkdir -p "$NVM_DIR"
#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
#nvm install --lts
#
#npm ci || npm install
#npm run build
#
## Configure NGINX
#echo "🌐 Configuring NGINX..."
#cat >/etc/nginx/sites-available/razor <<EOF
#server {
#    listen 80;
#    server_name _;
#
#    root /home/razor/razor/public;
#    index index.php index.html;
#
#    location / {
#        try_files \$uri /index.php?\$query_string;
#    }
#
#    location ~ \.php\$ {
#        include snippets/fastcgi-php.conf;
#        fastcgi_pass unix:$FPM_SOCKET;
#    }
#
#    location ~ /\.ht {
#        deny all;
#    }
#}
#EOF
#
#ln -sf /etc/nginx/sites-available/razor /etc/nginx/sites-enabled/
#rm -f /etc/nginx/sites-enabled/default
#systemctl restart nginx
#
## Enable firewall
#ufw allow OpenSSH
#ufw allow "Nginx Full"
#ufw --force enable
#
#echo "✅ Razor installed. Visit your server IP in the browser to access it."
#

#!/bin/bash
set -e

# Entry point for Razor setup script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/php.sh"
source "$SCRIPT_DIR/lib/razor.sh"
source "$SCRIPT_DIR/lib/nginx.sh"

install_dependencies
build_php_from_source
setup_php_fpm_service
install_composer_for_php
clone_razor_repo
setup_env_and_permissions
install_node_and_build_assets
configure_nginx
enable_firewall

echo "✅ Razor is ready at your server IP."
