@echo off
echo 🔧 CORRIGIENDO ERRORES DE DEPENDENCIAS Y TIPOS
echo ============================================

echo.
echo 📁 Navegando al directorio del proyecto...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo ✅ Directorio: %cd%

echo.
echo 🔄 PASO 1: Corrigiendo conflicto de dependencias intl
echo ==================================================
echo 📝 Reemplazando pubspec.yaml con versiones compatibles...

REM Hacer backup del pubspec actual
copy pubspec.yaml pubspec_backup.yaml >nul 2>&1

REM Usar el pubspec corregido
copy pubspec_fixed_intl.yaml pubspec.yaml

echo ✅ pubspec.yaml actualizado con intl ^0.20.2

echo.
echo 🧹 PASO 2: Limpiar cache y reinstalar dependencias
echo =================================================
call flutter clean
if %errorlevel% neq 0 (
    echo ❌ Error en flutter clean
    pause
    exit /b 1
)

call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error en flutter pub get
    echo 💡 Verifica que las versiones sean compatibles
    pause
    exit /b 1
)

echo ✅ Dependencias instaladas correctamente

echo.
echo 🔧 PASO 3: Verificar que Firebase Auth esté habilitado
echo ===================================================
echo 📝 IMPORTANTE: Ve a Firebase Console y verifica:
echo    1. Authentication → Comenzar (si no está iniciado)
echo    2. Sign-in method → Email/Password → Habilitar
echo    3. Firestore Database → Crear (si no existe)
echo.
echo 🌐 URL: https://console.firebase.google.com/project/gestion-de-inventario-8d16a/authentication
echo.

echo ⚠️  ¿Has verificado que Authentication esté habilitado? (s/n)
set /p auth_enabled="Respuesta: "

if /i "%auth_enabled%" neq "s" (
    echo.
    echo ❌ Ve a Firebase Console y habilita Authentication primero
    echo 🔗 https://console.firebase.google.com/project/gestion-de-inventario-8d16a/authentication
    echo.
    pause
    exit /b 1
)

echo.
echo 🚀 PASO 4: Ejecutar la app
echo ========================
echo 📱 Ejecutando flutter run...

call flutter run
if %errorlevel% neq 0 (
    echo ❌ Error ejecutando la app
    echo 💡 Revisa los errores de compilación arriba
    pause
    exit /b 1
)

echo.
echo 🎉 ¡App ejecutándose!
echo 📋 Próximos pasos:
echo    1. Prueba "Registrar nueva empresa" 
echo    2. Si sigue dando error, comparte el error específico
echo.
pause
