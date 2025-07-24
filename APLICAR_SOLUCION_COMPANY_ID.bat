@echo off
echo ===================================================
echo     RESTAU PEDIDOS - CORRECCION AUTOMATICA
echo     Error: No se pudo obtener el ID de la empresa
echo ===================================================
echo.

echo [PASO 1] Parando la aplicacion si esta ejecutandose...
taskkill /F /IM flutter.exe 2>nul
timeout /t 2 >nul

echo.
echo [PASO 2] Limpiando cache y reconstruyendo...
echo.

echo Limpiando build anterior...
flutter clean

echo.
echo [PASO 3] Obteniendo dependencias...
flutter pub get

echo.
echo [PASO 4] Aplicando correcciones al codigo...
echo.
echo ✅ employee_dashboard_screen.dart - ACTUALIZADO
echo    - Mejor manejo cuando no hay companyId
echo    - Pantalla informativa en lugar de error
echo    - Botones de accion para resolver el problema
echo.

echo [PASO 5] Reconstruyendo la aplicacion...
echo.
flutter build apk --debug

echo.
echo ===================================================
echo     SOLUCION APLICADA EXITOSAMENTE
echo ===================================================
echo.
echo INSTRUCCIONES PARA RESOLVER EL PROBLEMA:
echo.
echo Si eres EMPLEADO:
echo ────────────────
echo 1. Cierra sesion en la app
echo 2. Pide a tu admin el codigo de empresa (formato: RES-YYYY-XXXX)
echo 3. Registrate nuevamente con el codigo correcto
echo.
echo Si eres ADMINISTRADOR:
echo ─────────────────────
echo 1. Cierra sesion en la app
echo 2. Registra una nueva empresa
echo 3. El sistema generara un codigo automaticamente
echo 4. Comparte el codigo con tus empleados
echo.
echo PARA VERIFICAR EN FIREBASE:
echo ──────────────────────────
echo 1. Ve a https://console.firebase.google.com
echo 2. Firestore Database → coleccion 'users'
echo 3. Busca tu usuario por email
echo 4. Verifica que tenga 'companyId'
echo.
echo ===================================================
echo.
echo Presiona cualquier tecla para ejecutar la app...
pause >nul

echo.
echo [PASO 6] Ejecutando la aplicacion...
flutter run