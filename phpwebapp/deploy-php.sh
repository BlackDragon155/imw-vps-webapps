#!/usr/bin/env bash
set -euo pipefail

# =========================================================
# Despliegue de aplicación PHP con Nginx + PHP-FPM
# Estilo equivalente al script de despliegue de Go
# =========================================================

# ----------- Configuración ----------
INSTALL_DIR="/var/www/phpapp"
APP_PORT=8081                           # Puerto fijo en 8081
SERVICE_NAME="nginx"                     # En PHP usamos nginx, no systemd personalizado
APP_USER="phpweb"                        # Usuario del servicio
NGINX_SITE="/etc/nginx/sites-available/phpapp"
NGINX_SITE_LINK="/etc/nginx/sites-enabled/phpapp"

# Archivos PHP esperados en la MISMA carpeta que el script
FILES=("index.php" "contacto.php" "style.css")

log(){ printf "\n\033[1;34m[INFO]\033[0m %s\n" "$*"; }
require_root(){ [[ $EUID -eq 0 ]] || { echo "[ERROR] Ejecuta este script como root o con sudo."; exit 1; }; }

# 0) Requisitos
require_root

# 1) Instalar Nginx + PHP-FPM
log "Actualizando sistema e instalando Nginx y PHP-FPM…"
apt update
apt install -y nginx php-fpm

# Detectar versión del socket PHP-FPM
log "Detectando socket PHP-FPM…"
PHP_SOCK=$(find /run/php -name "php*-fpm.sock" | head -n 1)

if [[ -z "$PHP_SOCK" ]]; then
    echo "[ERROR] No se detectó ningún socket PHP-FPM."
    exit 1
fi
log "Usando socket: $PHP_SOCK"

# 2) Usuario del servicio
if ! id -u "$APP_USER" >/dev/null 2>&1; then
  log "Creando usuario del servicio: $APP_USER"
  useradd --system --no-create-home --shell /usr/sbin/nologin "$APP_USER"
fi

# 3) Crear directorio
log "Creando carpeta de despliegue en $INSTALL_DIR…"
mkdir -p "$INSTALL_DIR"

# 4) Copiar archivos PHP de la carpeta donde está el script
log "Copiando archivos PHP y CSS…"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for f in "${FILES[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$f" ]]; then
        echo "[ERROR] Falta el archivo: $f  (debe estar en la misma carpeta que este script)"
        exit 1
    fi
    cp "$SCRIPT_DIR/$f" "$INSTALL_DIR/"
done

# Permisos
chown -R "$APP_USER":"$APP_USER" "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"

# 5) Crear configuración Nginx propia (NO sobreescribe la default)
log "Creando configuración Nginx para el sitio en puerto $APP_PORT…"

cat > "$NGINX_SITE" <<EOF
server {
    listen ${APP_PORT};
    listen [::]:${APP_PORT};

    root ${INSTALL_DIR};
    index index.php;

    server_name _;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:${PHP_SOCK};
    }
}
EOF

# Enlace simbólico
ln -sf "$NGINX_SITE" "$NGINX_SITE_LINK"

# Desactivar el default
rm -f /etc/nginx/sites-enabled/default

# 6) Firewall
if command -v ufw >/dev/null 2>&1; then
    if ufw status | grep -q "Status: active"; then
        log "Abriendo puerto $APP_PORT/TCP en UFW…"
        ufw allow "${APP_PORT}/tcp" || true
    fi
fi

# 7) Reiniciar Nginx
log "Validando configuración Nginx…"
nginx -t

log "Recargando Nginx…"
systemctl reload nginx

# 8) Resumen
echo
echo "=============================================="
echo "    DESPLIEGUE PHP COMPLETADO"
echo "----------------------------------------------"
echo "Carpeta de despliegue:   $INSTALL_DIR"
echo "Puerto configurado:      $APP_PORT"
echo "Usuario del servicio:    $APP_USER"
echo
echo "Archivos instalados:"
for f in "${FILES[@]}"; do echo " - $f"; done
echo
echo "Accede en:"
echo "  http://$(hostname -I | awk '{print $1}'):$APP_PORT/"
echo "=============================================="
