<?php
// Información del cliente y del servidor
$fecha = date("d/m/Y H:i:s");
$ip = $_SERVER['REMOTE_ADDR'] ?? 'Desconocida';
$navegador = $_SERVER["HTTP_USER_AGENT"] ?? 'No disponible';
$php_version = phpversion();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Página principal dinámica</title>
    <!-- Enlace al archivo CSS externo -->
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Aplicación web dinámica (PHP + Nginx)</h1>
    <h2>Hecho por: Daniel Gonzalez Velez, Javier Alamo y Nahuel</h2>

    <div class="section">
        <strong>Nombre del lenguaje de programación:</strong> PHP
    </div>

    <div class="section">
        <strong>Enlace:</strong>
        <a class="contact" href="contacto.php">Contacto</a>
    </div>

    <div class="section">
        <h2>Información del cliente y servidor</h2>
        <div class="info">
            <p><strong>Fecha y hora actual (servidor):</strong> <?php echo htmlspecialchars($fecha); ?></p>
            <p><strong>Dirección IP del cliente:</strong> <?php echo htmlspecialchars($ip); ?></p>
            <p><strong>Navegador del cliente:</strong> <?php echo htmlspecialchars($navegador); ?></p>
            <p><strong>Versión de PHP:</strong> <?php echo htmlspecialchars($php_version); ?></p>
            <p><strong>Resolución de pantalla:</strong> <span id="resolution">Detectando...</span></p>
        </div>
    </div>

    <script>
        // Mostrar resolución de pantalla del cliente
        const resolution = `${window.screen.width} x ${window.screen.height} pixels`;
        document.getElementById('resolution').textContent = resolution;
    </script>
</body>
</html>