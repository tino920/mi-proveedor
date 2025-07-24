@echo off
echo 🔍 DIAGNOSTICO RAPIDO - MiProveedor
echo =====================================

echo.
echo 📋 Verificando requisitos...

REM Test Node.js
echo 🧪 Probando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js NO instalado
    echo 🔗 Descarga: https://nodejs.org/
    echo.
    echo ⚠️  PROBLEMA ENCONTRADO: Instala Node.js primero
    pause
    exit /b 1
) else (
    for /f %%i in ('node --version') do echo ✅ Node.js instalado: %%i
)

REM Test Flutter
echo 🧪 Probando Flutter...
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter NO disponible
    echo 📝 Verifica que Flutter esté en PATH
    echo.
    echo ⚠️  PROBLEMA ENCONTRADO: Flutter no encontrado
    pause
    exit /b 1
) else (
    echo ✅ Flutter disponible
)

REM Test Firebase CLI
echo 🧪 Probando Firebase CLI...
firebase --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ⚠️  Firebase CLI no instalado (se instalará automáticamente)
) else (
    for /f %%i in ('firebase --version') do echo ✅ Firebase CLI: %%i
)

echo.
echo 🎯 DIAGNÓSTICO COMPLETADO
echo ========================

echo ✅ Todos los requisitos están listos
echo 🚀 Ahora puedes ejecutar la configuración completa

echo.
echo 💡 SIGUIENTE PASO:
echo    Ejecuta: SETUP_FIREBASE_REAL.bat
echo.

pause
