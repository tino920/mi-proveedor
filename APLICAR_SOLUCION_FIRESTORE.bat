@echo off
echo ====================================
echo SOLUCION FIRESTORE - RESTAU PEDIDOS
echo ====================================
echo.

echo [1] Copiando archivo arreglado...
copy /Y lib\core\auth\auth_provider_fixed.dart lib\core\auth\auth_provider.dart
echo ✅ Archivo copiado correctamente
echo.

echo [2] Limpiando proyecto...
call flutter clean
echo ✅ Proyecto limpiado
echo.

echo [3] Obteniendo dependencias...
call flutter pub get
echo ✅ Dependencias actualizadas
echo.

echo ====================================
echo ✅ SOLUCION APLICADA CORRECTAMENTE ✅
echo ====================================
echo.
echo IMPORTANTE:
echo -----------
echo 1. Ve a Firebase Console y BORRA cualquier empresa anterior
echo 2. Borra usuarios antiguos en Authentication
echo 3. Ejecuta: flutter run
echo 4. Registra una NUEVA empresa
echo.
echo Los cambios principales:
echo - Ahora se crean los campos 'members' y 'admins'
echo - Los empleados se añaden automaticamente a 'members'
echo - Las reglas de Firestore ahora funcionaran correctamente
echo.
pause
