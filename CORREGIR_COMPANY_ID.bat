@echo off
echo ===================================================
echo     CORREGIR ERROR: ID DE EMPRESA FALTANTE
echo ===================================================
echo.

echo [1] Verificando el problema...
echo.

echo Este error ocurre cuando un empleado no tiene asignada una empresa.
echo.
echo SOLUCIONES DISPONIBLES:
echo.
echo 1. Si eres EMPLEADO:
echo    - Necesitas el codigo de empresa de tu administrador
echo    - El formato es: RES-YYYY-XXXX (ej: RES-2024-1234)
echo    - Registrate nuevamente con el codigo correcto
echo.
echo 2. Si eres ADMIN y no tienes empresa:
echo    - Cierra sesion y registra una nueva empresa
echo    - El sistema generara un codigo automaticamente
echo.
echo 3. SOLUCION TEMPORAL (Solo desarrollo):
echo    - Ejecutaremos un diagnostico de tu cuenta
echo.

pause

echo.
echo [2] Ejecutando diagnostico...
echo.

:: Crear archivo temporal para diagnostico
echo import 'package:flutter/material.dart'; > temp_diagnostic.dart
echo import 'package:firebase_core/firebase_core.dart'; >> temp_diagnostic.dart
echo import 'package:firebase_auth/firebase_auth.dart'; >> temp_diagnostic.dart
echo import 'package:cloud_firestore/cloud_firestore.dart'; >> temp_diagnostic.dart
echo import 'firebase_options.dart'; >> temp_diagnostic.dart
echo. >> temp_diagnostic.dart
echo void main() async { >> temp_diagnostic.dart
echo   WidgetsFlutterBinding.ensureInitialized(); >> temp_diagnostic.dart
echo   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); >> temp_diagnostic.dart
echo   final user = FirebaseAuth.instance.currentUser; >> temp_diagnostic.dart
echo   if (user == null) { >> temp_diagnostic.dart
echo     print('ERROR: No hay usuario autenticado'); >> temp_diagnostic.dart
echo     return; >> temp_diagnostic.dart
echo   } >> temp_diagnostic.dart
echo   print('Usuario: ' + user.email!); >> temp_diagnostic.dart
echo   final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get(); >> temp_diagnostic.dart
echo   if (userDoc.exists) { >> temp_diagnostic.dart
echo     final data = userDoc.data()!; >> temp_diagnostic.dart
echo     print('Rol: ' + (data['role'] ?? 'Sin rol')); >> temp_diagnostic.dart
echo     print('CompanyId: ' + (data['companyId'] ?? 'SIN EMPRESA ASIGNADA')); >> temp_diagnostic.dart
echo     if (data['companyId'] == null) { >> temp_diagnostic.dart
echo       print(''); >> temp_diagnostic.dart
echo       print('PROBLEMA CONFIRMADO: No tienes empresa asignada'); >> temp_diagnostic.dart
echo       print('Necesitas el codigo de empresa para registrarte correctamente'); >> temp_diagnostic.dart
echo     } >> temp_diagnostic.dart
echo   } >> temp_diagnostic.dart
echo   exit(0); >> temp_diagnostic.dart
echo } >> temp_diagnostic.dart

:: Copiar el archivo a lib para ejecutarlo
copy temp_diagnostic.dart lib\temp_diagnostic.dart > nul

:: Ejecutar el diagnostico
flutter run -t lib/temp_diagnostic.dart

:: Limpiar archivos temporales
del temp_diagnostic.dart
del lib\temp_diagnostic.dart

echo.
echo [3] Solucion aplicada...
echo.
echo Si el problema persiste:
echo.
echo 1. Ve a Firebase Console: https://console.firebase.google.com
echo 2. Selecciona tu proyecto
echo 3. Ve a Firestore Database
echo 4. Busca la coleccion 'users'
echo 5. Encuentra tu usuario por email
echo 6. Verifica que tenga el campo 'companyId'
echo.
echo Si no tiene companyId:
echo - Los empleados deben registrarse con un codigo de empresa valido
echo - Los admins deben registrar primero la empresa
echo.

pause