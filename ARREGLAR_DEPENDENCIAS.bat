@echo off
echo 🔧 ARREGLANDO ERROR DE DEPENDENCIAS
echo =================================

echo.
echo 📁 Navegando al directorio...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo ✅ Directorio: %cd%

echo.
echo 🔄 PASO 1: Corrigiendo pubspec.yaml...
echo ⚠️  Problema: intl ^0.19.0 vs requerido ^0.20.2

if exist "pubspec_fixed_intl.yaml" (
    copy "pubspec_fixed_intl.yaml" "pubspec.yaml"
    echo ✅ pubspec.yaml corregido (intl: ^0.20.2)
) else (
    echo ❌ Archivo de corrección no encontrado
    exit /b 1
)

echo.
echo 🧹 PASO 2: Limpieza profunda...
call flutter clean
if exist "pubspec.lock" del "pubspec.lock"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo 📦 PASO 3: Reinstalar dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error instalando dependencias
    echo 💡 Probando método alternativo...
    call flutter pub upgrade
)

echo.
echo 🏃‍♂️ PASO 4: Ejecutar app...
call flutter run --web-port=8080
if %errorlevel% neq 0 (
    echo ❌ Error ejecutando app
    echo 📋 Verificando errores de compilación...
    call flutter analyze
)

echo.
echo 🎯 PROCESO COMPLETADO
pause
