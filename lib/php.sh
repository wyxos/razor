#!/bin/bash

install_dependencies() {
  apt update && apt install -y \
    build-essential \
    autoconf \
    bison \
    re2c \
    libxml2-dev \
    libsqlite3-dev \
    libcurl4-openssl-dev \
    libzip-dev \
    libonig-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    libfreetype6-dev \
    libssl-dev \
    pkg-config \
    unzip \
    wget \
    git \
    curl \
    nginx \
    supervisor \
    ufw

  if ! id "razor" &>/dev/null; then
    adduser --disabled-password --gecos "" razor
  fi
}

build_php_from_source() {
  if [ -x "$INSTALL_DIR/bin/php" ]; then
    read -p "⚠️  PHP $PHP_VERSION already installed. Reinstall? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      echo "➡️  Skipping PHP build."
      return
    fi
    rm -rf "$INSTALL_DIR"
  fi

  mkdir -p "$INSTALL_DIR"
  cd /usr/src
  wget https://www.php.net/distributions/php-$PHP_VERSION.tar.gz
  tar -xzf php-$PHP_VERSION.tar.gz
  cd php-$PHP_VERSION

  ./configure \
    --prefix=$INSTALL_DIR \
    --with-config-file-path=$INSTALL_DIR/etc \
    --with-config-file-scan-dir=$INSTALL_DIR/etc/conf.d \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --enable-mbstring \
    --with-curl \
    --with-openssl \
    --with-zlib \
    --with-zip \
    --with-sqlite3 \
    --with-pdo-sqlite \
    --enable-soap \
    --enable-bcmath \
    --with-jpeg \
    --with-webp \
    --with-freetype \
    --enable-gd

  echo "⏳ Building PHP..."
  make -s -j$(nproc)
  make -s install

  ln -sf "$INSTALL_DIR/bin/php" /usr/bin/php84
}

install_composer_for_php() {
  curl -sS https://getcomposer.org/installer | php84 -- --install-dir=$INSTALL_DIR/bin --filename=composer
  ln -sf "$INSTALL_DIR/bin/composer" /usr/bin/composer84
}

setup_php_fpm_service() {
  mkdir -p "$INSTALL_DIR/etc/php-fpm.d"
  cat > "$INSTALL_DIR/etc/php-fpm.d/www.conf" <<EOF
[www]
user = www-data
group = www-data
listen = $FPM_SOCKET
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOF

  echo "include=$INSTALL_DIR/etc/php-fpm.d/*.conf" > "$INSTALL_DIR/etc/php-fpm.conf"

  cat > /etc/systemd/system/php84-fpm.service <<EOF
[Unit]
Description=PHP 8.4 FPM
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/sbin/php-fpm --nodaemonize --fpm-config $INSTALL_DIR/etc/php-fpm.conf
ExecReload=/bin/kill -USR2 $MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  mkdir -p /run/php
  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable php84-fpm
  systemctl start php84-fpm
}
