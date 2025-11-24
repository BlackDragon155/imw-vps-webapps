# 📘 README.md — Proyecto JavaScript con Node.js, Express y systemd
## Proyecto Web en Node.js con Express  
### Servidor HTTP/HTTPS + Servicio systemd

Este proyecto implementa una aplicación web desarrollada con **JavaScript**, utilizando **Node.js** y **Express**.  
Incluye:

- Servidor HTTP/HTTPS  
- Página principal con información del cliente  
- Página de contacto  
- Integración de certificados locales con mkcert  
- Arranque automático mediante **systemd**

---

## 📦 Requisitos previos

Asegúrate de tener instalado en tu sistema:

- Node.js (versión 20 recomendada)
- npm
- mkcert (para HTTPS local)
- Ubuntu 24.04 con systemd

---

## 🚀 Instalación del entorno

### 1. Instalar Node.js y npm

```bash
sudo apt install nodejs npm -y
node -v
npm -v
```

Si necesitas actualizar Node.js a la versión 20:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

## 📁 Estructura del proyecto

```go
ProyectoJS/
│
├── app.js
├── contact.html
├── package.json
└── node_modules/
```

## 📦 Inicialización del proyecto
1. Crear carpeta del proyecto

```bash
mkdir ProyectoJS
cd ProyectoJS
chmod -R 777 ProyectoJS
```

2. Inicializar npm

```bash
npm init -y
```

3. Instalar Express

```bash
npm install express
```

## 🧩 Archivos principales
**app.js**

Servidor Node.js con Express, capaz de mostrar:

- IP del cliente

- Fecha y hora

- Navegador

- Versión de JavaScript

- Resolución de pantalla

(Ver sección “Código fuente” más abajo)

**contact.html**

Formulario básico con envío de datos simulados.

## ▶️ Ejecución del servidor

```bash
node app.js
```

#### Accede desde el navegador:

```bash
http://localhost:9090/
```

## 🔧 Crear servicio systemd

#### Crear archivo:

```bash
sudo nano /etc/systemd/system/mi-web.service
```

#### Contenido:

```ini
[Unit]
Description=Mi aplicación web con Node.js
After=network.target

[Service]
ExecStart=/usr/bin/node /ProyectoJS/app.js
Restart=always
User=isard
Environment=NODE_ENV=production
WorkingDirectory=/ProyectoJS/

[Install]
WantedBy=multi-user.target
```

#### Activar el servicio:

```bash
sudo systemctl daemon-reload
sudo systemctl enable mi-web.service
sudo systemctl start mi-web.service
sudo systemctl status mi-web.service
```

## 🔒 Habilitar HTTPS con mkcert
### 1. Instalar herramientas

```bash
sudo apt install libnss3-tools
sudo apt install mkcert
```

### 2. Crear autoridad certificadora

```bash
mkcert -install
```

### 3. Generar certificados para localhost

```bash
mkcert localhost
```

#### Esto genera:


- localhost.pem

- localhost-key.pem

### 4. Dar permisos

```bash
sudo chown isard:isard /ProyectoJS/localhost*.pem
sudo chmod 600 /ProyectoJS/localhost-key.pem
sudo chmod 644 /ProyectoJS/localhost.pem
```

### 5. Reiniciar servicio

```bash
sudo systemctl daemon-reload
sudo systemctl restart mi-web.service
```

## 🛠 Problemas comunes
### ❌ Error: versiones antiguas de Node.js

### Solución:

```bash
nvm install 20
nvm use 20
rm -rf node_modules package-lock.json
npm install
```

### ❌ Error de ruta: archivo no encontrado

### Solución:

```bash
cd /ProyectoJS
node app.js
```

### ❌ HTTPS no funciona tras crear certificados

### Solución:

Revisar permisos y reiniciar systemd.

## 🧾 Código fuente

```javascript
app.js
const express = require('express');
const path = require('path');
const fs = require('fs');
const https = require('https');
const app = express();
const port = 9090;

const options = {
  key: fs.readFileSync('/ProyectoJS/localhost-key.pem'),
  cert: fs.readFileSync('/ProyectoJS/localhost.pem')
};

app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname));

app.get('/', (req, res) => {
  const ipHeader = req.headers['x-forwarded-for'];
  const ip = (ipHeader && ipHeader.split(',')[0]) || req.ip;
  const horaActual = new Date().toLocaleString();

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    <head>
      <meta charset="UTF-8" />
      <title>Página Principal</title>
    </head>
    <body>
      <h1>Información del Cliente</h1>
      <p><strong>Hora:</strong> ${horaActual}</p>
      <p><strong>IP:</strong> ${ip}</p>
      <button onclick="window.location.href='/contact.html'">Contacto</button>
    </body>
    </html>
  `;
  res.send(html);
});

https.createServer(options, app).listen(port, () => {
  console.log(`Servidor HTTPS escuchando en https://localhost:${port}`);
});
```
