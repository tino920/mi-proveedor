@echo off
echo 🚀 MobilePro - PUSH CAMBIOS Y TRIGGER BUILD
echo ========================================

echo.
echo 📤 AÑADIENDO ARCHIVOS...
git add .

echo.
echo 💬 COMMIT CON MENSAJE...
git commit -m "🔧 FIX: Cache corruption solved - amplify references removed"

echo.
echo 🚀 PUSH A GITHUB (AUTO-TRIGGER BUILD)...
git push origin main

echo.
echo ✅ BUILD TRIGGERED AUTOMÁTICAMENTE
echo 📊 Monitorear en: https://github.com/tino920/mi-proveedor/actions
echo.
echo ⏱️ Build iniciará en 1-2 minutos...
echo.
pause
