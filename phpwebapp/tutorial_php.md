# Tutorial: Despliegue de Aplicación Web PHP con Nginx + PHP-FPM

Este tutorial explica cómo desplegar una aplicación web básica escrita en PHP
usando Nginx como servidor web y PHP-FPM como intérprete del lenguaje.

---

## 1️⃣ Introducción

PHP (Hypertext Preprocessor) es un lenguaje interpretado diseñado para el desarrollo web.
Permite generar contenido dinámico en el servidor y enviarlo al navegador del usuario.
Se integra fácilmente con bases de datos y es ampliamente utilizado en aplicaciones web.

En esta práctica desplegaremos la aplicación **sin frameworks**, directamente con PHP y Nginx.

---

## 2️⃣ Requisitos previos

- Servidor Ubuntu/Debian limpio.
- Acceso con usuario con permisos de `sudo`.
- Archivos de la aplicación:
  - `index.php`
  - `contacto.php`
  - `style.css`
- Script de despliegue: `deploy-php.sh`

---

## 3️⃣ Actualizar el sistema

Antes de instalar paquetes, actualizamos los repositorios y actualizamos el sistema:

```bash
sudo apt update && sudo apt upgrade -y
```
4️⃣ Instalar Nginx y PHP-FPM

Instalamos los servicios necesarios:

```bash
sudo apt install nginx php-fpm -y
```
Comprobamos que los servicios están activos:

```bash
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
```
Nota: Ajusta la versión de PHP-FPM según la que se haya instalado (8.3, 8.2, etc.).

5️⃣ Crear el directorio de la aplicación

Creamos la carpeta donde se desplegará la aplicación y ajustamos permisos:

```bash
sudo mkdir -p /var/www/phpapp
sudo chown -R $USER:$USER /var/www/phpapp
```
Verificamos que se creó correctamente:

```bash
ls /var/www
```
6️⃣ Copiar los archivos de la aplicación

Suponiendo que index.php, contacto.php y style.css están en la misma carpeta que el script,
los copiamos al directorio web:

```bash
sudo cp index.php contacto.php style.css /var/www/phpapp/
```
7️⃣ Configuración de Nginx

Antes de modificar, hacemos una copia de seguridad del archivo default:

```bash
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.copia
```
Editamos el bloque de servidor para nuestra app:

```bash
sudo nano /etc/nginx/sites-available/default
```
Ejemplo de configuración:

```nginx
server {
    listen 8081 default_server;
    listen [::]:8081 default_server;

    root /var/www/phpapp;
    index index.php index.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
    }
}
```
8️⃣ Probar y recargar Nginx
```bash
sudo nginx -t
sudo systemctl reload nginx
```
9️⃣ Abrir el puerto en el firewall (UFW)

Si UFW está activo, abrimos el puerto configurado (8081):

```bash
sudo ufw allow 8081
sudo ufw reload
```
1️⃣0️⃣ Acceder a la aplicación
Desde un navegador, ingresamos a:

```cpp
http://<IP-del-servidor>:8081/
```
Allí se verá la página principal (index.php) y se podrá navegar al enlace de contacto (contacto.php).

1️⃣1️⃣ Cambiar el puerto (opcional)

Para usar otro puerto diferente a 8081, editamos las líneas listen en:

```swift
/etc/nginx/sites-available/default
```
Por ejemplo, para el puerto 9090:

```nginx
listen 9090 default_server;
listen [::]:9090 default_server;
```
Recargamos Nginx:

```bash
sudo systemctl reload nginx
```
Y abrimos el puerto en UFW si es necesario:

```bash
sudo ufw allow 9090
sudo ufw reload
```
1️⃣2️⃣ Notas finales

Todos los archivos PHP y CSS deben tener permisos correctos para ser leídos por Nginx.

Cada vez que modifiques archivos PHP, no es necesario reiniciar PHP-FPM, pero si cambias la configuración de Nginx, sí.

Este tutorial se centra en un despliegue básico para fines educativos, sin frameworks ni bases de datos.