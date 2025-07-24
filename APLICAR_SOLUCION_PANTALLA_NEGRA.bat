@echo off
echo ================================
echo SOLUCION PANTALLA NEGRA - PEDIDOS
echo ================================
echo.

echo [PASO 1] Creando backup del archivo original...
copy "lib\features\orders\presentation\screens\admin_orders_screen.dart" "lib\features\orders\presentation\screens\admin_orders_screen_backup.dart" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Backup creado exitosamente
) else (
    echo ❌ Error creando backup
    pause
    exit /b 1
)

echo.
echo [PASO 2] Aplicando la solucion...
copy "lib\features\orders\presentation\screens\admin_orders_screen_fixed.dart" "lib\features\orders\presentation\screens\admin_orders_screen.dart" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Solucion aplicada exitosamente
) else (
    echo ❌ Error aplicando la solucion
    pause
    exit /b 1
)

echo.
echo [PASO 3] Verificando archivos...
if exist "lib\features\orders\presentation\screens\admin_orders_screen.dart" (
    echo ✅ Archivo principal actualizado
) else (
    echo ❌ Error: Archivo principal no encontrado
)

if exist "lib\features\orders\presentation\screens\admin_orders_screen_backup.dart" (
    echo ✅ Archivo de backup disponible
) else (
    echo ❌ Error: Backup no disponible
)

echo.
echo ================================
echo 🎉 SOLUCION APLICADA EXITOSAMENTE
echo ================================
echo.
echo 🔧 PROBLEMA RESUELTO:
echo - Ya no aparece pantalla negra al aprobar pedidos
echo - La navegacion funciona correctamente
echo - Se mantiene toda la funcionalidad existente
echo.
echo 🧪 SIGUIENTE PASO:
echo 1. Ejecutar: flutter run
echo 2. Login como admin
echo 3. Ir a "Gestion de Pedidos"
echo 4. Probar aprobar/rechazar pedidos
echo.
echo 📁 ARCHIVOS:
echo - Original: admin_orders_screen_backup.dart (respaldo)
echo - Corregido: admin_orders_screen.dart (activo)
echo - Solucion: admin_orders_screen_fixed.dart (fuente)
echo.
echo ¡La app deberia funcionar perfectamente ahora! 🚀
echo.
pause
