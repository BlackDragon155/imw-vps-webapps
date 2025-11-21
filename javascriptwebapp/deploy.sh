#!/usr/bin/env bash
set -euo pipefail

# ==========================================
# Despliegue de App Node.js + Express
# Ubuntu 24.04 — Servicio systemd
# Basado SOLO en el tutorial proporcionado
# ==========================================

APP_DIR="/opt/ProyectoJS"
SERVICE_NAME="mi-web.service"
APP_USER="nodeapp"
APP_PORT="8082"

log() { printf "\n\033[1;34m[INFO]\033[0m %s\n" "$*"; }

# Requiere root
if [[ $EUID -ne 0 ]]; then
  echo "[ERROR] Ejecuta este script con sudo o como root"
  exit 1
fi

# 1) Instalar Node.js y npm (como en el tutorial)
log "Instalando Node.js y npm..."
apt update
apt install -y nodejs npm

log "Versiones instaladas:"
node -v
npm -v

# 2) Crear usuario de servicio
if ! id -u "$APP_USER" >/dev/null 2>&1; then
  log "Creando usuario del servicio: $APP_USER"
  useradd --system --no-create-home --shell /usr/sbin/nologin "$APP_USER"
fi

# 3) Copiar proyecto
log "Preparando carpeta $APP_DIR..."
mkdir -p "$APP_DIR"

log "Copiando archivos del proyecto..."
cp -r ./* "$APP_DIR"

# 4) Instalar dependencias npm
log "Instalando dependencias npm..."
cd "$APP_DIR"
npm install express

# 5) Permisos
log "Asignando permisos..."
chown -R "$APP_USER":"$APP_USER" "$APP_DIR"
chmod -R 755 "$APP_DIR"

# 6) Crear servicio systemd (según el tutorial)
log "Creando servicio systemd /etc/systemd/system/$SERVICE_NAME"

cat > "/etc/systemd/system/$SERVICE_NAME" <<EOF
[Unit]
Description=Mi aplicación web con Node.js
After=network.target

[Service]
ExecStart=/usr/bin/node $APP_DIR/app.js
Restart=always
User=$APP_USER
Environment=NODE_ENV=production
WorkingDirectory=$APP_DIR

[Install]
WantedBy=multi-user.target
EOF

# 7) Abrir puerto en UFW si está activo
if command -v ufw >/dev/null 2>&1; then
  if ufw status | grep -q "Status: active"; then
    log "Abriendo puerto $APP_PORT en UFW..."
    ufw allow "$APP_PORT"/tcp || true
  fi
fi

# 8) Activar servicio
log "Habilitando y arrancando el servicio..."
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
systemctl restart "$SERVICE_NAME"

systemctl --no-pager --full status "$SERVICE_NAME" || true

echo
echo "=============================================="
echo " Despliegue completado"
echo "----------------------------------------------"
echo "Carpeta:        $APP_DIR"
echo "Servicio:       $SERVICE_NAME"
echo "Puerto:         $APP_PORT"
echo "Usuario:        $APP_USER"
echo
echo "Accede a:"
echo "  http://<IP>:8082/"
echo "=============================================="
