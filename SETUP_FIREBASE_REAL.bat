@echo off
echo 🔥 CONFIGURACION FIREBASE REAL - RestauPedidos
echo ==============================================

echo.
echo 📋 VERIFICANDO REQUISITOS PREVIOS...

REM Verificar Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js no está instalado
    echo 🔗 Descarga desde: https://nodejs.org/
    echo 📝 Instala Node.js y vuelve a ejecutar este script
    pause
    exit /b 1
) else (
    echo ✅ Node.js instalado
)

REM Verificar Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Flutter no está disponible en PATH
    echo 📝 Verifica que Flutter esté instalado y en PATH
    pause
    exit /b 1
) else (
    echo ✅ Flutter disponible
)

echo.
echo 🚀 INSTALANDO HERRAMIENTAS FIREBASE...

REM Instalar Firebase CLI
echo 📦 Instalando Firebase CLI...
call npm install -g firebase-tools
if %errorlevel% neq 0 (
    echo ❌ Error instalando Firebase CLI
    pause
    exit /b 1
)

REM Instalar FlutterFire CLI
echo 📦 Instalando FlutterFire CLI...
call dart pub global activate flutterfire_cli
if %errorlevel% neq 0 (
    echo ❌ Error instalando FlutterFire CLI
    pause
    exit /b 1
)

echo ✅ Herramientas instaladas correctamente

echo.
echo 🔐 PASO 1: AUTENTICACIÓN FIREBASE
echo ================================
echo.
echo 📝 Se abrirá tu navegador para autenticarte en Firebase
echo    ↳ Usa tu cuenta Google para autenticarte
echo.
pause

call firebase login
if %errorlevel% neq 0 (
    echo ❌ Error en autenticación Firebase
    pause
    exit /b 1
)

echo ✅ Autenticación exitosa

echo.
echo 📋 PROYECTOS FIREBASE DISPONIBLES:
call firebase projects:list

echo.
echo 🏗️ PASO 2: CREAR NUEVO PROYECTO (OPCIONAL)
echo =========================================
echo.
echo ¿Quieres crear un nuevo proyecto Firebase? (s/n)
set /p create_project="Respuesta: "

if /i "%create_project%"=="s" (
    echo.
    echo 📝 Ingresa un ID único para tu proyecto:
    echo    Ejemplo: restau-pedidos-tu-apellido
    set /p project_id="Project ID: "
    
    echo 🏗️ Creando proyecto Firebase...
    call firebase projects:create %project_id% --display-name "RestauPedidos"
    
    if %errorlevel% neq 0 (
        echo ❌ Error creando proyecto. Verifica que el ID sea único
        echo 💡 Intenta con otro nombre como: restau-pedidos-%random%
        pause
        exit /b 1
    )
    
    echo ✅ Proyecto creado: %project_id%
)

echo.
echo 🔧 PASO 3: CONFIGURAR FLUTTER CON FIREBASE
echo =========================================
echo.
echo 📁 Navegando al directorio del proyecto...
cd /d "C:\Users\danie\Downloads\tu_proveedor"

echo ✅ Directorio actual: %cd%

echo.
echo 🔄 Configurando FlutterFire...
echo 📝 Selecciona tu proyecto cuando te lo pida
echo    ↳ Usa las flechas para navegar y ENTER para seleccionar
echo    ↳ Habilita TODAS las plataformas (Android, iOS, Web, macOS)
echo.
pause

call flutterfire configure
if %errorlevel% neq 0 (
    echo ❌ Error configurando FlutterFire
    echo 💡 Verifica que hayas seleccionado un proyecto válido
    pause
    exit /b 1
)

echo ✅ FlutterFire configurado correctamente

echo.
echo 📋 VERIFICANDO ARCHIVOS GENERADOS...

if exist "lib\firebase_options.dart" (
    echo ✅ firebase_options.dart generado
) else (
    echo ❌ firebase_options.dart NO generado
)

if exist "android\app\google-services.json" (
    echo ✅ google-services.json generado
) else (
    echo ⚠️ google-services.json NO encontrado
)

echo.
echo 🧹 LIMPIANDO Y PREPARANDO PROYECTO...
call flutter clean
call flutter pub get

echo.
echo 🎯 CONFIGURACIÓN COMPLETADA
echo ==========================
echo.
echo ✅ Firebase CLI instalado y configurado
echo ✅ FlutterFire configurado con TU proyecto
echo ✅ Archivos de configuración generados
echo ✅ Dependencias actualizadas
echo.
echo 📋 PRÓXIMOS PASOS MANUALES:
echo.
echo 1. 🌐 Ve a Firebase Console: https://console.firebase.google.com
echo 2. 🔐 Habilita Authentication → Email/Password
echo 3. 🗄️ Crea Firestore Database (modo producción)
echo 4. 📁 Habilita Storage
echo 5. ⚙️ Configura reglas de seguridad
echo.
echo 🚀 ¿Quieres ejecutar la app ahora? (s/n)
set /p run_app="Respuesta: "

if /i "%run_app%"=="s" (
    echo.
    echo 🏃‍♂️ Ejecutando la app...
    call flutter run
) else (
    echo.
    echo ✅ Para ejecutar manualmente: flutter run
)

echo.
echo 🎉 ¡Configuración Firebase Real Completada!
echo 📖 Lee CONFIGURACION_FIREBASE_REAL.md para más detalles
pause
