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
    <head> 
      <meta charset="UTF-8" /> 
      <meta name="viewport" content="width=device-width, initial-scale=1.0" /> 
      <title>Página Principal</title> 
      <style> 
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
          background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%); 
          color: #fff; 
          display: flex; 
          justify-content: center; 
          align-items: center; 
          height: 100vh; 
          margin: 0; 
          flex-direction: column; 
          text-align: center; 
        } 
        .container { 
          background: rgba(0, 0, 0, 0.4); 
          padding: 2rem 3rem; 
          border-radius: 12px; 
          box-shadow: 0 8px 24px rgba(0,0,0,0.2); 
          max-width: 400px; 
        } 
        button { 
          margin-top: 1rem; 
          padding: 10px 20px; 
          font-size: 1rem; 
          border: none; 
          border-radius: 5px; 
          cursor: pointer; 
          background: #2575fc; 
          color: #fff; 
        } 
      </style> 
    </head> 
    <body> 
      <div class="container"> 
        <h1>Información del Cliente</h1> 
        <p><strong>Hora:</strong> ${horaActual}</p> 
        <p><strong>IP:</strong> ${ip}</p> 
        <p id="browserInfo"></p> 
        <p id="screenInfo"></p> 
        <button onclick="window.location.href='/contact.html'">Contacto</button> 
      </div> 
 
      <script> 
        const browser = navigator.userAgent; 
        const jsVersion = (() => { 
          try { new Function('() => {}'); return 'ES6+'; } 
          catch(e) { return 'ES5 o inferior'; } 
        })(); 
        const screenResolution = window.screen.width + 'x' + window.screen.height; 
 
        document.getElementById('browserInfo').innerText = 'Navegador: ' + browser 
+ ' | JS: ' + jsVersion; 
        document.getElementById('screenInfo').innerText = 'Resolución: ' + 
screenResolution; 
      </script> 
    </body> 
    </html> 
  `; 
 
  res.send(html); 
}); 
 
 
https.createServer(options, app).listen(port, () => { 
  console.log(`Servidor HTTPS escuchando en https://localhost:${port}`); 
});
