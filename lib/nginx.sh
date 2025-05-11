#!/bin/bash

configure_nginx() {
  echo "🌐 Configuring NGINX..."
  cat >/etc/nginx/sites-available/razor <<EOF
server {
    listen 80;
    server_name _;

    root $APP_DIR/public;
    index index.php index.html;

    location / {
        try_files \$uri /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$FPM_SOCKET;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

  ln -sf /etc/nginx/sites-available/razor /etc/nginx/sites-enabled/
  rm -f /etc/nginx/sites-enabled/default
  systemctl restart nginx
}

enable_firewall() {
  ufw allow OpenSSH
  ufw allow "Nginx Full"
  ufw --force enable
}
