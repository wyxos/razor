#!/bin/bash

clone_razor_repo() {
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
  git clone "$REPO_URL" "$APP_DIR" || { echo "Clone failed, aborting."; exit 1; }

  # ✅ Fix ownership after clone
  chown -R razor:razor "$APP_DIR"

  # Mark the repo as safe for Git
  sudo -u razor git config --global --add safe.directory "$APP_DIR"
}

setup_env_and_permissions() {
  cd "$APP_DIR"
  chown -R www-data:www-data .
  chmod o+rx /home/razor
  chmod -R o+rw storage bootstrap/cache

  cp .env.example .env

  touch database/database.sqlite
  chown www-data:www-data database/database.sqlite
  chmod 664 database/database.sqlite
  chmod o+rx database

  php84 /usr/bin/composer84 install --no-dev --optimize-autoloader
  php84 artisan key:generate
  php84 artisan migrate --force
}

install_node_and_build_assets() {
  export NVM_DIR="$NVM_DIR"
  mkdir -p "$NVM_DIR"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm install --lts

  npm ci || npm install
  npm run build
}
