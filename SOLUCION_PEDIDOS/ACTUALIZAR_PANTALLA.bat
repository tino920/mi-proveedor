@echo off
echo ========================================
echo 🔧 ACTUALIZANDO PANTALLA DE PEDIDOS
echo ========================================
echo.

cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo 📁 Creando backup del archivo actual...
copy "lib\features\orders\presentation\screens\employee_orders_screen.dart" "SOLUCION_PEDIDOS\employee_orders_screen_backup.dart"

echo 📋 Copiando versión corregida...
copy "SOLUCION_PEDIDOS\employee_orders_screen_fixed.dart" "lib\features\orders\presentation\screens\employee_orders_screen.dart"

echo 🧹 Limpiando cache...
flutter clean

echo 📦 Reinstalando dependencias...
flutter pub get

echo.
echo ✅ ¡Actualización completada!
echo.
echo 🚀 Ahora ejecuta: flutter run
echo 📱 Y prueba la pestaña "Pedidos" en tu app
echo.
pause
