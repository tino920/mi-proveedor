@echo off
echo 🚀 SOLUCIONANDO PROBLEMA DE LOGIN - RestauPedidos
echo =================================================

echo.
echo 📁 Navegando al directorio del proyecto...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo ✅ Directorio actual: %cd%

echo.
echo 💾 Creando backup del archivo original...
if exist "lib\firebase_options.dart" (
    copy "lib\firebase_options.dart" "lib\firebase_options_backup.dart"
    echo ✅ Backup creado: firebase_options_backup.dart
) else (
    echo ⚠️  Archivo firebase_options.dart no encontrado
)

echo.
echo 🔄 Reemplazando con configuración funcional...
if exist "lib\firebase_options_working.dart" (
    copy "lib\firebase_options_working.dart" "lib\firebase_options.dart"
    echo ✅ Archivo reemplazado con configuración funcional
) else (
    echo ❌ Error: firebase_options_working.dart no encontrado
    echo    Ejecuta primero el análisis desde Claude
    pause
    exit /b 1
)

echo.
echo 🧹 Limpiando cache de Flutter...
call flutter clean

echo.
echo 📦 Instalando dependencias...
call flutter pub get

echo.
echo 🎯 CONFIGURACIÓN COMPLETADA
echo ========================
echo.
echo 📋 CREDENCIALES DE PRUEBA:
echo    👤 Admin: admin@test.com
echo    🔑 Password: Test123456
echo.
echo    👤 Empleado: empleado@test.com  
echo    🔑 Password: Test123456
echo.
echo    🏢 Código Empresa: TEST-2024-1234
echo.

echo 🚀 ¿Quieres ejecutar la app ahora? (s/n)
set /p choice="Respuesta: "

if /i "%choice%"=="s" (
    echo.
    echo 🏃‍♂️ Ejecutando la app...
    call flutter run
) else (
    echo.
    echo ✅ Para ejecutar manualmente usa: flutter run
    echo 📁 Desde el directorio: %cd%
)

echo.
echo 🎉 ¡Listo! La app debería funcionar ahora.
pause
