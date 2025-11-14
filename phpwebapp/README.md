# Despliegue de Aplicación PHP con Nginx + PHP-FPM

Este directorio contiene todo lo necesario para desplegar una aplicación PHP simple
utilizando **Nginx** y **PHP-FPM**, siguiendo el estándar de despliegue pedido en la práctica.

## 📁 Contenido de esta carpeta

- `deploy-php.sh` — Script de despliegue automático.
- `index.php` — Página principal de la aplicación.
- `contacto.php` — Formulario de contacto simple.
- `style.css` — Archivo CSS usado por la aplicación.
- `tutorial_php.md` — Documento explicativo del funcionamiento de la aplicación.
- `README.md` — Este archivo.

---

## 🚀 Cómo ejecutar el script de despliegue

### 1) Dar permisos de ejecución

```bash
chmod +x deploy-php.sh
```

2) Ejecutar el script (con root o sudo)
```bash
sudo ./deploy-php.sh
```

El script realizará las siguientes tareas automáticamente:

✔ Instalar Nginx y PHP-FPM

✔ Detectar el socket PHP-FPM correcto

✔ Crear un usuario de servicio dedicado (phpweb)

✔ Copiar los archivos de la aplicación a /var/www/phpapp

✔ Crear una configuración de Nginx específica en el puerto 8081

✔ Recargar Nginx

✔ Abrir el puerto en UFW (si está activo)

## 🌐 Acceder a la aplicación

Tras la ejecución del script, el terminal mostrará algo como:
```bash
Accede en: http://<IP>:8081/
```

Solo sustituye 
```bash
<IP>
``` 
por la IP real de tu máquina servidor.

🧹 Cómo eliminar el despliegue (si lo necesitas)
```bash
sudo rm -rf /var/www/phpapp
sudo rm -f /etc/nginx/sites-available/phpapp
sudo rm -f /etc/nginx/sites-enabled/phpapp
sudo userdel phpweb
sudo systemctl reload nginx
```
📌 Notas

Si modificas cualquiera de los archivos PHP o CSS, deberás volver a ejecutar el script.

Puedes cambiar el puerto editando la variable APP_PORT dentro de deploy-php.sh (actualmente está fijado en 8081).