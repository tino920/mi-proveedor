@echo off
setlocal enabledelayedexpansion

echo.
echo ==========================================
echo 🚀 SUBIR MIPROVEEDOR A GITHUB - MobilePro
echo ==========================================
echo.

REM 🔍 1. Verificar Git
echo 📋 1. Verificando Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Git no está instalado
    echo 💡 Descarga Git desde: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✅ Git instalado correctamente

REM 🗂️ 2. Verificar directorio del proyecto
if not exist "lib" (
    echo ❌ ERROR: No estás en el directorio correcto del proyecto
    echo 💡 Ejecuta este script desde: C:\Users\danie\Downloads\tu_proveedor\
    pause
    exit /b 1
)
echo ✅ Directorio del proyecto correcto

REM 🔧 3. Inicializar Git (si no existe)
echo.
echo 🔧 2. Inicializando repositorio Git...
if not exist ".git" (
    git init
    echo ✅ Repositorio Git inicializado
) else (
    echo ✅ Repositorio Git ya existe
)

REM 📋 4. Configurar Git (si no está configurado)
echo.
echo 📋 3. Verificando configuración Git...

for /f "tokens=*" %%a in ('git config --global user.name 2^>nul') do set "git_name=%%a"
for /f "tokens=*" %%a in ('git config --global user.email 2^>nul') do set "git_email=%%a"

if "!git_name!"=="" (
    set /p git_name="👤 Introduce tu nombre para Git: "
    git config --global user.name "!git_name!"
)

if "!git_email!"=="" (
    set /p git_email="📧 Introduce tu email para Git: "
    git config --global user.email "!git_email!"
)

echo ✅ Git configurado: !git_name! ^<!git_email!^>

REM 📦 5. Añadir archivos al repositorio
echo.
echo 📦 4. Añadiendo archivos al repositorio...
git add .
echo ✅ Archivos añadidos

REM 💾 6. Hacer commit
echo.
echo 💾 5. Creando commit...
git commit -m "🚀 MiProveedor iOS listo - Configurado por MobilePro

✅ Características:
- Flutter 3.16+ con Firebase completo
- Sistema 5 idiomas (es, en, ca, fr, it)
- Autenticación biométrica iOS/Android
- GitHub Actions para build iOS automático
- Arquitectura modular profesional
- Bundle ID: com.miproveedor.app

🍎 iOS Build:
- AppDelegate.swift con Firebase
- Podfile optimizado para iOS 12.0+
- Permisos configurados en Info.plist
- Script setup automático incluido

🤖 Android:
- Completamente funcional
- Firebase configurado
- APK listo para distribución

🔧 Desarrollado por MobilePro
📱 Listo para App Store y Google Play"

if errorlevel 1 (
    echo ⚠️ No hay cambios para hacer commit (probablemente ya está actualizado)
) else (
    echo ✅ Commit realizado exitosamente
)

REM 🌐 7. Configurar repositorio remoto
echo.
echo 🌐 6. Configurando repositorio GitHub...
echo.
echo 📋 INSTRUCCIONES:
echo 1. Ve a https://github.com y haz login
echo 2. Haz clic en "+" (arriba derecha) → "New repository"
echo 3. Nombre del repositorio: mi-proveedor
echo 4. Descripción: "🍽️ MiProveedor - Gestión inteligente de pedidos para restaurantes"
echo 5. Selecciona "Public" (o Private si prefieres)
echo 6. NO marques "Initialize with README" (ya tenemos uno)
echo 7. Haz clic en "Create repository"
echo 8. Copia la URL que aparece (ejemplo: https://github.com/TU_USUARIO/mi-proveedor.git)
echo.

set /p repo_url="🔗 Introduce la URL de tu repositorio GitHub: "

if "!repo_url!"=="" (
    echo ❌ ERROR: URL del repositorio es requerida
    pause
    exit /b 1
)

REM Verificar si ya existe origin
git remote get-url origin >nul 2>&1
if not errorlevel 1 (
    echo 🔄 Actualizando URL del repositorio remoto...
    git remote set-url origin !repo_url!
) else (
    echo 🔗 Añadiendo repositorio remoto...
    git remote add origin !repo_url!
)

echo ✅ Repositorio remoto configurado: !repo_url!

REM 🚀 8. Subir a GitHub
echo.
echo 🚀 7. Subiendo proyecto a GitHub...
echo ⏳ Esto puede tardar unos minutos la primera vez...

git branch -M main
git push -u origin main

if errorlevel 1 (
    echo.
    echo ❌ ERROR: No se pudo subir a GitHub
    echo.
    echo 💡 POSIBLES SOLUCIONES:
    echo 1. Verifica que la URL del repositorio sea correcta
    echo 2. Asegúrate de tener permisos en el repositorio
    echo 3. Si es la primera vez, GitHub puede pedir autenticación:
    echo    - Username: tu usuario de GitHub
    echo    - Password: usa un Personal Access Token (no tu contraseña)
    echo.
    echo 🔑 Para crear un Personal Access Token:
    echo 1. Ve a GitHub → Settings → Developer Settings → Personal Access Tokens
    echo 2. Genera un nuevo token con permisos "repo"
    echo 3. Usa ese token como contraseña
    echo.
    pause
    exit /b 1
)

REM ✅ 9. Éxito completo
echo.
echo ==========================================
echo 🎉 ¡PROYECTO SUBIDO A GITHUB EXITOSAMENTE!
echo ==========================================
echo.
echo ✅ COMPLETADO:
echo   📦 Repositorio Git inicializado
echo   📁 Todos los archivos añadidos
echo   💾 Commit inicial creado
echo   🔗 Repositorio remoto configurado
echo   🚀 Código subido a GitHub
echo.
echo 📋 ARCHIVOS INCLUIDOS:
echo   ✅ README.md profesional
echo   ✅ GitHub Actions para iOS
echo   ✅ AppDelegate.swift con Firebase
echo   ✅ Podfile optimizado
echo   ✅ Todo el código Flutter
echo.
echo 🎯 PRÓXIMOS PASOS:
echo.
echo 1. 🌐 Ve a tu repositorio: !repo_url!
echo 2. 🔍 Verifica que todos los archivos estén ahí
echo 3. 🍎 Ve a "Actions" para ver el build iOS
echo 4. ⚡ El build automático empezará en unos minutos
echo.
echo 📱 GITHUB ACTIONS:
echo   • Se ejecutará automáticamente
echo   • Compilará tu app para iOS
echo   • Generará archivo .ipa
echo   • Podrás descargarlo desde "Actions"
echo.
echo 💡 RECUERDA:
echo   • El build puede tardar 10-15 minutos
echo   • Recibirás notificación por email
echo   • El .ipa estará sin firmar (para testing)
echo.
echo 🎉 ¡Tu proyecto MiProveedor está listo!
echo    Desarrollado por MobilePro ✨
echo.

REM 🌐 10. Abrir repositorio en navegador (opcional)
set /p open_browser="🌐 ¿Abrir repositorio en navegador? (s/n): "
if /i "!open_browser!"=="s" (
    start !repo_url!
)

echo.
echo 📞 SOPORTE:
echo   Si tienes problemas, revisa los logs de GitHub Actions
echo   o contacta al desarrollador MobilePro
echo.
pause
