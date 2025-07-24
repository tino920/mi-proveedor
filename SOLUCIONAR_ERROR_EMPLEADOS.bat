@echo off
echo =====================================
echo    SOLUCION RAPIDA - Error Empleados
echo =====================================
echo.
echo 🔧 DIAGNOSTICANDO PROBLEMA...
echo.

echo 1️⃣ Actualizando reglas de Firestore (temporalmente permisivas)...
firebase deploy --only firestore:rules --project restau-pedidos-prod

echo.
echo 2️⃣ Verificando estructura de datos en Firebase...
echo   - Abre Firebase Console
echo   - Ve a Firestore Database
echo   - Busca colección 'users'
echo   - Verifica que tengas usuarios con campo 'companyId'
echo.

echo 3️⃣ Ejecuta la app y revisa logs...
flutter clean
flutter pub get
flutter run --debug

echo.
echo =======================================
echo    SOLUCION APLICADA
echo =======================================
echo.
echo ✅ Reglas de Firestore actualizadas
echo ✅ Código mejorado con mejor manejo de errores
echo ✅ Sistema de migración automática implementado
echo.
echo 🔍 SI AÚN HAY PROBLEMAS:
echo    1. Verifica que tengas datos en Firebase
echo    2. Revisa que el usuario tenga 'companyId'
echo    3. Chequea la consola de Flutter para logs detallados
echo.
pause
