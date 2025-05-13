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

  # Make everything owned by razor
  chown -R razor:razor .

  # Ensure Laravel required dirs are writeable
  chmod -R u+rwX storage bootstrap/cache

  # Make public/ readable by nginx
  chmod -R o+rx public

  # Setup environment
  cp .env.example .env
  chown razor:razor .env

  # SQLite database permissions
  touch database/database.sqlite
  chown razor:razor database/database.sqlite
  chmod 664 database/database.sqlite
  chmod o+rx database

  # Run install commands as razor
  sudo -u razor php84 /usr/bin/composer84 install --no-dev --optimize-autoloader
  sudo -u razor php84 artisan key:generate
  sudo -u razor php84 artisan migrate --force
}

install_node_and_build_assets() {
  export NVM_DIR="$NVM_DIR"
  mkdir -p "$NVM_DIR"
  chown -R razor:razor "$NVM_DIR"

  sudo -u razor bash -c "
    export NVM_DIR='$NVM_DIR'
    [ -s '\$NVM_DIR/nvm.sh' ] || curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    [ -s '\$NVM_DIR/nvm.sh' ] && . '\$NVM_DIR/nvm.sh'
    nvm install --lts
    cd '$APP_DIR'
    npm ci || npm install
    npm run build
  "
}
