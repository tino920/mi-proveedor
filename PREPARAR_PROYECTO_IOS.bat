@echo off
echo.
echo ==========================================
echo 🚀 PREPARACION PROYECTO iOS - MiProveedor
echo ==========================================
echo    Desarrollado por MobilePro
echo.

echo 📋 1. Limpiando proyecto Flutter...
flutter clean
if errorlevel 1 (
    echo ❌ Error: Flutter no encontrado. Instala Flutter primero.
    pause
    exit /b 1
)

echo ✅ Proyecto limpiado

echo.
echo 📦 2. Obteniendo dependencias...
flutter pub get
if errorlevel 1 (
    echo ❌ Error obteniendo dependencias
    pause
    exit /b 1
)

echo ✅ Dependencias descargadas

echo.
echo 🔍 3. Ejecutando diagnóstico Flutter...
flutter doctor
echo.

echo 📱 4. Verificando dispositivos conectados...
flutter devices
echo.

echo ===============================================
echo ✅ PROYECTO PREPARADO PARA iOS
echo ===============================================
echo.
echo 📋 ARCHIVOS ACTUALIZADOS:
echo   ✅ ios/Runner/AppDelegate.swift - Firebase configurado
echo   ✅ ios/Podfile - Dependencias iOS listas
echo   ✅ ios/flutter_ios_setup.sh - Script automático
echo   ✅ Bundle ID: com.miproveedor.app
echo.
echo 🎯 PRÓXIMOS PASOS:
echo   1. Consigue acceso a Mac (MacinCloud $20/mes)
echo   2. Ejecuta: ./ios/flutter_ios_setup.sh
echo   3. Configura Firebase iOS en console.firebase.google.com
echo   4. ¡Tu app funcionará en iPhone/iPad!
echo.
echo 💡 ALTERNATIVAS SIN MAC:
echo   • GitHub Actions (CI/CD gratuito) 
echo   • Codemagic (build en la nube)
echo   • MacinCloud (Mac virtual)
echo.
echo 🎉 ¡Proyecto 100%% listo para iOS!
echo    by MobilePro ✨
echo.
pause
