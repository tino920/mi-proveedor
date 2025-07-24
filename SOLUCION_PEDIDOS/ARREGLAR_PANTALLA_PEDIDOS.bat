@echo off
echo ========================================
echo 🚀 SOLUCIONANDO PANTALLA DE PEDIDOS 
echo ========================================
echo.

echo 🧹 Limpiando cache de Flutter...
cd /d "C:\Users\danie\Downloads\tu_proveedor"
flutter clean

echo.
echo 📦 Reinstalando dependencias...
flutter pub get

echo.
echo 🔥 Reiniciando Flutter con hot restart...
echo IMPORTANTE: Presiona 'R' (mayúscula) cuando se inicie la app
echo.

flutter run --verbose

echo.
echo ✅ ¡Listo! Tu pantalla de pedidos debería funcionar ahora.
pause
