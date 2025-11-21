## 📌 Introducción

### Este proyecto consiste en desarrollar una aplicación web utilizando:

- JavaScript

- Node.js como entorno de ejecución

- Express como framework web

### El objetivo es:

- Mostrar información del cliente (fecha/hora, IP, navegador, versión JS, resolución de pantalla)

- Incluir un formulario de contacto

- Añadir HTTPS con certificados locales (mkcert)

- Crear un servicio systemd que arranque automáticamente la aplicación

## ⚙️ Implementación
### Construcción del servidor

Se utiliza una máquina virtual con Ubuntu Desktop para poder realizar pruebas gráficas.

### Cambiar el Host

```bash
hostnamectl set-hostname servidorJS
```

### Instalación de paquetes

Instalar Node.js y npm:

```bash
sudo apt install nodejs npm -y
```

Comprobar versiones:

```bash
node -v
npm -v
```

### Inicialización del proyecto
#### Creación de la carpeta
```bash
mkdir ProyectoJS
chmod -R 777 ProyectoJS
```

### Inicialización de npm

Dentro de ProyectoJS:

```bash
npm init -y
```

Esto crea:

```json
{
  "name": "proyectojs",
  "version": "1.0.0",
  "main": "index.js",
  "license": "ISC"
}
```

### Instalación de Express

```bash
npm install express
```

### Creación de los archivos web

```bash
nano app.js
nano contact.html
```

## ▶️ Iniciación del Servidor

Ejecutar la aplicación:

```bash
node app.js
```

Acceso por:

```bash
127.0.0.1
```

## 🔄 Inicio automático del servicio
Crear un servicio en systemd

```bash
cd /etc/systemd/system/
nano mi-web.service
```

### Contenido:

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

### Implementación del servicio y del servidor

```bash
sudo systemctl daemon-reload
sudo systemctl enable mi-web.service
sudo systemctl start mi-web.service
sudo systemctl status mi-web.service
```

## 🔒 Asegurar nuestra conexión
### Instalación de mkcert y libnss3-tools

```bash
sudo apt install libnss3-tools
sudo apt install mkcert
```

### Generar la autoridad certificadora local

```bash
mkcert -install
```

### Añadir certificación al servidor

```bash
mkcert localhost
```

Genera:

localhost.pem → certificado

localhost-key.pem → clave privada

### Modificar app.js

Se debe configurar la app para usar HTTPS (ver código fuente más abajo).

### Reinicio y relanzamiento del servicio

```bash
sudo systemctl daemon-reload
sudo systemctl restart mi-web.service
sudo systemctl status mi-web.service
```

## ⚠️ Problemas más comunes
Versiones desfasadas de Node.js

Express puede fallar en Node.js 14.

### Solución:

Instalar nvm:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

Reinstalar dependencias:

```bash
rm -rf node_modules package-lock.json
npm install
```

### Alternativa rápida

```bash
npm install express@4
```

### Errores de ruta

Si aparece:

```javascript
Error: Cannot find module '/home/isard/app.js'
```

Solución:

```bash
cd /ProyectoJS
node app.js
```

### Sitio no disponible tras certificar

Solución de permisos:

```bash
sudo chown isard:isard /ProyectoJS/localhost*.pem
sudo chmod 600 /ProyectoJS/localhost-key.pem
sudo chmod 644 /ProyectoJS/localhost.pem
```

Reiniciar servicios:

```bash
sudo systemctl daemon-reload
sudo systemctl restart mi-web.service
```

## 🧩 Código fuente

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

// Middleware para parsear datos del formulario
app.use(express.urlencoded({ extended: true }));

// Servir archivos HTML estáticos
app.use(express.static(__dirname));

app.get('/', (req, res) => {
  const ipHeader = req.headers['x-forwarded-for'];
  const ip = (ipHeader && ipHeader.split(',')[0]) || req.ip;
  const horaActual = new Date().toLocaleString();

  const html = `
    <!DOCTYPE html>
    <html lang="es">
    ...
    </html>
  `;

  res.send(html);
});

https.createServer(options, app).listen(port, () => {
  console.log(\`Servidor HTTPS escuchando en https://localhost:\${port}\`);
});
```

## Formulario (contact.html)

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Formulario de Contacto</title>
  <style>
    ...
  </style>
</head>
<body>
  <div class="form">
    <h2>Formulario de Contacto</h2>
    <form method="POST" action="/submit" id="contactForm">
      ...
    </form>
  </div>

  <script>
    const browser = navigator.userAgent;
    ...
  </script>
</body>
</html>
```