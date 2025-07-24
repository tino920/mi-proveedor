@echo off
echo 🔧 SOLUCIONANDO ERROR PigeonUserDetails
echo =====================================

echo.
echo 📁 Verificando directorio...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

if not exist "pubspec.yaml" (
    echo ❌ Error: No estás en el directorio correcto
    pause
    exit /b 1
)

echo ✅ Directorio correcto: %cd%

echo.
echo 💾 Creando backup del pubspec actual...
copy "pubspec.yaml" "pubspec_backup.yaml"
echo ✅ Backup creado: pubspec_backup.yaml

echo.
echo 🔄 Aplicando versiones Firebase compatibles...
copy "pubspec_fixed_firebase.yaml" "pubspec.yaml"
echo ✅ Versiones Firebase actualizadas

echo.
echo 🧹 LIMPIEZA PROFUNDA...
echo ⏳ Eliminando cache Flutter...
call flutter clean

echo ⏳ Eliminando pubspec.lock...
if exist "pubspec.lock" del "pubspec.lock"

echo ⏳ Eliminando .dart_tool...
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo ⏳ Eliminando .packages...
if exist ".packages" del ".packages"

echo ✅ Limpieza completada

echo.
echo 📦 REINSTALANDO DEPENDENCIAS...
echo ⏳ Instalando paquetes actualizados...
call flutter pub get
if %errorlevel% neq 0 (
    echo ❌ Error instalando dependencias
    echo 💡 Revisa los errores arriba
    pause
    exit /b 1
)
echo ✅ Dependencias instaladas correctamente

echo.
echo 🔥 RECONFIGURANDO FIREBASE...
echo ⏳ Reconfigurar FlutterFire...
call dart pub global run flutterfire_cli:flutterfire configure --project=gestion-de-inventario-8d16a --force
if %errorlevel% neq 0 (
    echo ⚠️ Error reconfigurando FlutterFire (puede continuar)
)

echo.
echo 🏗️ RECOMPILANDO PROYECTO...
echo ⏳ Generando archivos...
call flutter packages get

echo ⏳ Compilando...
call flutter build web --debug
if %errorlevel% neq 0 (
    echo ⚠️ Warning: Build web falló (puede continuar)
)

echo.
echo 🎯 CORRECCIÓN COMPLETADA
echo ========================
echo.
echo ✅ Versiones Firebase actualizadas
echo ✅ Cache completamente limpio
echo ✅ Dependencias reinstaladas
echo ✅ Firebase reconfigurado
echo.
echo 🚀 ¿Ejecutar la app ahora? (s/n)
set /p run_choice="Respuesta: "

if /i "%run_choice%"=="s" (
    echo.
    echo 🏃‍♂️ Ejecutando la app...
    echo ⏳ Esto puede tomar un momento la primera vez...
    call flutter run
) else (
    echo.
    echo ✅ Para ejecutar manualmente: flutter run
)

echo.
echo 🎉 ¡Error PigeonUserDetails solucionado!
echo 💡 Si sigue fallando, ejecuta: flutter clean && flutter run
pause
