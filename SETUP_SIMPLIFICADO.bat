@echo off
echo 🔥 SETUP FIREBASE SIMPLIFICADO
echo ==============================

echo.
echo 📁 Navegando al directorio...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

if not exist "pubspec.yaml" (
    echo ❌ Error: No estás en el directorio correcto del proyecto
    echo 📁 Directorio actual: %cd%
    echo 📝 Asegúrate de estar en el directorio tu_proveedor
    pause
    exit /b 1
)

echo ✅ Directorio correcto: %cd%

echo.
echo 🔧 PASO 1: Instalar Firebase CLI
echo ===============================
echo 📝 Instalando Firebase CLI con npm...
call npm install -g firebase-tools
if %errorlevel% neq 0 (
    echo ❌ Error instalando Firebase CLI
    echo 💡 ¿Tienes Node.js instalado?
    echo 🔗 Descarga: https://nodejs.org/
    pause
    exit /b 1
)
echo ✅ Firebase CLI instalado

echo.
echo 🔧 PASO 2: Instalar FlutterFire CLI
echo ==================================
echo 📝 Instalando FlutterFire CLI...
call dart pub global activate flutterfire_cli
if %errorlevel% neq 0 (
    echo ❌ Error instalando FlutterFire CLI
    pause
    exit /b 1
)
echo ✅ FlutterFire CLI instalado

echo.
echo 🔐 PASO 3: Login Firebase
echo ========================
echo 📝 Abriendo navegador para autenticación...
echo ⚠️  IMPORTANTE: Completa el login en el navegador
echo.
pause

call firebase login
if %errorlevel% neq 0 (
    echo ❌ Error en login Firebase
    echo 💡 Asegúrate de completar el login en el navegador
    pause
    exit /b 1
)
echo ✅ Login Firebase exitoso

echo.
echo 📋 PASO 4: Ver proyectos disponibles
echo ===================================
call firebase projects:list
echo.
echo 💡 Si no tienes proyectos, ve a: https://console.firebase.google.com
echo    y crea un nuevo proyecto llamado: restau-pedidos-tuapellido
echo.

echo ⚠️  ¿Ya tienes un proyecto o acabas de crear uno?
echo.
pause

echo.
echo 🔧 PASO 5: Configurar FlutterFire
echo ================================
echo 📝 Configurando proyecto Flutter con Firebase...
echo ⚠️  IMPORTANTE: 
echo    1. Selecciona tu proyecto de la lista
echo    2. Habilita TODAS las plataformas
echo.
pause

call flutterfire configure
if %errorlevel% neq 0 (
    echo ❌ Error configurando FlutterFire
    echo 💡 Asegúrate de haber seleccionado un proyecto válido
    pause
    exit /b 1
)
echo ✅ FlutterFire configurado

echo.
echo 🧹 PASO 6: Limpiar y preparar proyecto
echo =====================================
call flutter clean
call flutter pub get

echo.
echo 🎯 CONFIGURACIÓN COMPLETADA
echo ==========================
echo.
echo ✅ Firebase CLI configurado
echo ✅ FlutterFire configurado  
echo ✅ Proyecto limpio y listo
echo.
echo 📋 PASOS MANUALES RESTANTES:
echo.
echo 1. 🌐 Ve a: https://console.firebase.google.com
echo 2. 🔐 Habilita Authentication → Email/Password
echo 3. 🗄️ Crea Firestore Database
echo 4. 📁 Habilita Storage
echo.
echo 🚀 ¿Ejecutar la app ahora? (s/n)
set /p run_choice="Respuesta: "

if /i "%run_choice%"=="s" (
    echo.
    echo 🏃‍♂️ Ejecutando la app...
    call flutter run
) else (
    echo.
    echo ✅ Para ejecutar: flutter run
)

echo.
echo 🎉 ¡Setup completado!
pause
