# 🔥 CONFIGURACIÓN FIREBASE REAL - PASOS DETALLADOS

## 📋 REQUISITOS PREVIOS:
1. Cuenta Google activa
2. Node.js instalado (https://nodejs.org/)
3. Flutter instalado y funcionando

## 🚀 CONFIGURACIÓN PASO A PASO:

### PASO 1: INSTALAR HERRAMIENTAS FIREBASE
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Verificar instalación
firebase --version
flutterfire --version
```

### PASO 2: AUTENTICARSE EN FIREBASE
```bash
# Iniciar sesión en Firebase
firebase login

# Verificar proyectos disponibles
firebase projects:list
```

### PASO 3: CONFIGURAR PROYECTO
```bash
# Navegar a tu proyecto Flutter
cd "C:\Users\danie\Downloads\tu_proveedor"

# Configurar Firebase para este proyecto
flutterfire configure

# Cuando te pregunte:
# - Selecciona tu proyecto recién creado
# - Habilita todas las plataformas (Android, iOS, Web, macOS)
# - Confirma la configuración
```

### PASO 4: VERIFICAR ARCHIVOS GENERADOS
Después de `flutterfire configure` deberías tener:
```
✅ lib/firebase_options.dart (ACTUALIZADO con TUS credenciales)
✅ android/app/google-services.json
✅ ios/Runner/GoogleService-Info.plist
✅ macos/Runner/GoogleService-Info.plist
```

### PASO 5: CONFIGURAR REGLAS FIRESTORE
Ve a Firebase Console → Firestore → Reglas y copia esto:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso temporal para setup inicial
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### PASO 6: CONFIGURAR REGLAS STORAGE
Ve a Firebase Console → Storage → Reglas:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### PASO 7: EJECUTAR LA APP
```bash
# Limpiar cache
flutter clean

# Instalar dependencias
flutter pub get

# Ejecutar app
flutter run
```

## 🧪 TESTING:

### CREAR PRIMER USUARIO ADMIN:
1. Abrir la app
2. Seleccionar "Registrar Nueva Empresa"
3. Completar formulario:
   - Empresa: "Mi Restaurante"
   - Email: tu-email@gmail.com
   - Contraseña: Tu123456
   - Nombre: Tu Nombre

### VERIFICAR EN FIREBASE CONSOLE:
1. Authentication → Usuarios → Deberías ver tu usuario
2. Firestore → Colecciones → Deberías ver 'companies' y 'users'

## ❌ SOLUCIÓN DE ERRORES COMUNES:

### Error: "Firebase project not found"
```bash
firebase projects:list
# Verifica que tu proyecto existe y el nombre es correcto
```

### Error: "FlutterFire command not found"
```bash
# Agregar al PATH
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
# O en Windows, agregar C:\Users\[usuario]\AppData\Local\Pub\Cache\bin al PATH
```

### Error: "Google Services file missing"
```bash
# Re-ejecutar configuración
flutterfire configure --force
```

### Error de permisos Firestore:
1. Ve a Firebase Console → Firestore → Reglas
2. Cambia temporalmente a reglas permisivas (arriba)
3. Después de que funcione, implementa reglas más restrictivas

## 🎯 RESULTADO ESPERADO:
- ✅ Tu propia instancia Firebase funcionando
- ✅ Registro/login funcionando
- ✅ Datos guardándose en TU base de datos
- ✅ Control total sobre configuración
- ✅ Escalable para producción real

## 📞 SIGUIENTES PASOS:
Una vez funcionando:
1. Configurar reglas de seguridad más restrictivas
2. Configurar backup automático
3. Monitorear uso y costos
4. Configurar notificaciones push
5. Configurar analytics
