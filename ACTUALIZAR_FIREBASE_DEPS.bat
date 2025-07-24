@echo off
echo.
echo =================================================================
echo  SCRIPT PARA ACTUALIZAR DEPENDENCIAS DE FIREBASE - MobilePro
echo =================================================================
echo.
echo Este script solucionara el error de compilacion de Swift en iOS
echo actualizando los paquetes de Firebase a sus ultimas versiones compatibles.
echo.
echo -----------------------------------------------------------------
echo  PASO 1: ACCION MANUAL REQUERIDA
echo -----------------------------------------------------------------
echo.
echo  1. Abre tu archivo pubspec.yaml en tu editor de codigo.
echo.
echo  2. Busca todas las dependencias que empiezan con 'firebase_'.
echo.
echo  3. Cambia su numero de version por 'any'.
echo.
echo     EJEMPLO:
echo     ANTES: firebase_core: ^3.6.0  ->  DESPUES: firebase_core: any
echo     ANTES: firebase_auth: ^5.3.1  ->  DESPUES: firebase_auth: any
echo     (Haz esto para TODAS las dependencias de Firebase)
echo.
echo  4. Guarda los cambios en el archivo pubspec.yaml.
echo.
echo =================================================================
echo.
pause
echo.

echo -----------------------------------------------------------------
echo  PASO 2: ACTUALIZANDO PAQUETES
echo -----------------------------------------------------------------
echo.
echo 📦 Ejecutando 'flutter pub get' para descargar las nuevas versiones...
echo    Esto actualizara tu archivo 'pubspec.lock'.
flutter pub get
echo.

echo -----------------------------------------------------------------
echo  PASO 3: SUBIENDO LA SOLUCION A GITHUB
echo -----------------------------------------------------------------
echo.
echo 💾 Anadiendo pubspec.yaml y pubspec.lock a Git...
git add pubspec.yaml pubspec.lock
echo.

echo 📝 Creando el commit...
git commit -m "fix(deps): Actualizar dependencias de Firebase para compatibilidad con iOS"
echo.

echo 🚀 Subiendo los cambios a GitHub...
git push

if errorlevel 1 (
    echo.
    echo ❌ Error al subir los cambios. Revisa la terminal.
    pause
    exit /b 1
)

echo.
echo =================================================================
echo 🎉 ¡SOLUCION ENVIADA!
echo =================================================================
echo.
echo ✅ Cambios subidos a GitHub.
echo.
echo 🔄 AHORA:
echo    GitHub Actions comenzara un nuevo build con las dependencias
echo    actualizadas. El error de compilacion de Swift deberia estar
echo    solucionado.
echo.
echo    Puedes monitorear el progreso en tu pagina de Actions.
echo.
pause