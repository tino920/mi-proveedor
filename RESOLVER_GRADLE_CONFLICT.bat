@echo off
echo 🔧 SOLUCIONANDO CONFLICTO GOOGLE SERVICES
echo ========================================

echo 📁 Navegando al directorio del proyecto...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo 🧹 Limpiando Flutter...
call flutter clean

echo 📁 Entrando a carpeta android...
cd android

echo 🧹 Limpiando Gradle...
call gradlew clean

echo 🗑️ Eliminando cache de Gradle...
if exist ".gradle" (
    rmdir /s /q .gradle
    echo ✅ Cache .gradle eliminado
) else (
    echo ℹ️ No había cache .gradle
)

echo 📁 Volviendo al directorio principal...
cd ..

echo 🧹 Limpiando Flutter otra vez...
call flutter clean

echo 📦 Obteniendo dependencias...
call flutter pub get

echo 🎯 LIMPIEZA COMPLETADA
echo ===================

echo ✅ Conflicto de versiones resuelto
echo ✅ Cache completamente limpio
echo ✅ Dependencias actualizadas

echo.
echo 🚀 ¿Ejecutar la app ahora? (s/n)
set /p run_choice="Respuesta: "

if /i "%run_choice%"=="s" (
    echo.
    echo 🏃‍♂️ Ejecutando flutter run...
    call flutter run
) else (
    echo.
    echo ✅ Para ejecutar manualmente: flutter run
)

echo.
echo 🎉 ¡Problema resuelto!
pause
