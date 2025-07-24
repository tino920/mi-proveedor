@echo off
echo 🍎 CONFIGURACION RAPIDA iOS - MobilePro
echo =========================================

cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo.
echo 📱 1. Limpiando proyecto Flutter...
flutter clean

echo.
echo 📦 2. Instalando dependencias...
flutter pub get

echo.
echo 🩺 3. Verificando configuracion iOS...
flutter doctor

echo.
echo 📁 4. Configurando dependencias iOS...
cd ios
call pod install

echo.
echo ✅ CONFIGURACION COMPLETADA!
echo.
echo 📋 PROXIMOS PASOS:
echo 1. Descargar GoogleService-Info.plist de Firebase
echo 2. Colocarlo en ios\Runner\
echo 3. Abrir ios\Runner.xcworkspace en Xcode (necesitas Mac)
echo 4. Configurar Bundle ID: com.miproveedor.app
echo 5. Ejecutar: flutter run -d ios
echo.
echo 🎯 Bundle ID a usar: com.miproveedor.app
echo 📖 Ver GUIA_IOS_DESARROLLO.md para mas detalles
echo.
pause
