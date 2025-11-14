<?php
// Información del servidor para la página de contacto
$fecha = date("d/m/Y H:i:s");
$servidor = $_SERVER['SERVER_SOFTWARE'] ?? 'Desconocido';
$php_version = phpversion();
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Página de Contacto</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <h1>Página de Contacto</h1>
    <h2>Información de Contacto y Servidor</h2>

    <div class="section">
        <strong>Enlace:</strong>
        <a class="contact" href="index.php">Volver al Inicio</a>
    </div>

    <div class="section">
        <h3>Información del Servidor</h3>
        <div class="info">
            <p><strong>Fecha y hora actual:</strong> <?php echo htmlspecialchars($fecha); ?></p>
            <p><strong>Software del servidor:</strong> <?php echo htmlspecialchars($servidor); ?></p>
            <p><strong>Versión de PHP:</strong> <?php echo htmlspecialchars($php_version); ?></p>
            <p><strong>Directorio raíz:</strong> <?php echo htmlspecialchars($_SERVER['DOCUMENT_ROOT'] ?? 'Desconocido'); ?></p>
        </div>
    </div>

    <div class="section">
        <h3>Desarrolladores</h3>
        <div class="info">
            <p><strong>Daniel Gonzalez Velez</strong></p>
            <p><strong>Jose Fernando González Gil</strong></p>
            <p><strong>Derek Chocobollo</strong></p>
        </div>
    </div>
</body>
</html>
