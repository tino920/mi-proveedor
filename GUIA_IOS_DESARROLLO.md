# 📱 CONFIGURACIÓN iOS DEVELOPMENT - GUÍA PASO A PASO

## 🎯 OBJETIVO: Hacer funcionar la app en iOS para testing (SIN App Store)

---

## ⚡ PASOS RÁPIDOS (15 minutos)

### **PASO 1: Preparar Proyecto Flutter**

```bash
# En Terminal/CMD desde tu proyecto:
cd "C:\Users\danie\Downloads\tu_proveedor"
flutter clean
flutter pub get
flutter doctor
```

### **PASO 2: Configurar Firebase iOS**

1. **Firebase Console**: https://console.firebase.google.com/
2. **Tu proyecto** → ⚙️ **Project Settings**
3. **"Add app"** → **iOS**
4. **Bundle ID**: `com.miproveedor.app`
5. **App nickname**: "MiProveedor iOS"
6. **📥 Download GoogleService-Info.plist**

### **PASO 3: Integrar GoogleService-Info.plist**

```bash
# Copiar archivo descargado a:
C:\Users\danie\Downloads\tu_proveedor\ios\Runner\GoogleService-Info.plist
```

### **PASO 4: Configurar CocoaPods (dependencias iOS)**

```bash
# En Terminal:
cd "C:\Users\danie\Downloads\tu_proveedor\ios"
pod install
```

### **PASO 5: Configurar Bundle ID en Xcode**

```bash
# Abrir proyecto iOS:
# En iOS: Doble clic en ios/Runner.xcworkspace
# En Windows con VS Code: Necesitarás Mac para Xcode

# EN XCODE:
1. Seleccionar "Runner" en navegador izquierdo
2. "Signing & Capabilities"
3. Bundle Identifier: com.miproveedor.app
4. Team: [Tu Apple Developer Account]
5. ✅ "Automatically manage signing"
```

---

## 🔧 CONFIGURACIÓN MANUAL (Si no tienes Xcode)

### **Archivo iOS/Runner/Runner.xcodeproj/project.pbxproj**

Buscar líneas que contengan `PRODUCT_BUNDLE_IDENTIFIER` y cambiar a:
```
PRODUCT_BUNDLE_IDENTIFIER = com.miproveedor.app;
```

---

## 📱 TESTING EN iOS

### **OPCIÓN A: Con Mac + Xcode**
```bash
# Simulator
flutter run -d ios

# Dispositivo físico
flutter run -d [device-id]
```

### **OPCIÓN B: Sin Mac (Usando VS Code + Flutter)**
```bash
# Instalar extensión Flutter
# Conectar iPhone/iPad
flutter devices
flutter run -d [ios-device-id]
```

### **OPCIÓN C: Usando Codemagic/Bitrise (CI/CD)**
```bash
# Build en la nube sin Mac
# Descargar .ipa file
# Instalar vía TestFlight o Diawi
```

---

## 🚨 PROBLEMAS COMUNES

### **"No iOS devices available"**
```bash
SOLUCIÓN:
1. Conectar iPhone/iPad vía USB
2. Confiar en la computadora en iOS
3. flutter devices
```

### **"Signing certificate not found"**
```bash
SOLUCIÓN:
1. Crear Apple Developer Account (gratis)
2. En Xcode: Preferences → Accounts → Add Account
3. Automatically manage signing
```

### **"GoogleService-Info.plist not found"**
```bash
SOLUCIÓN:
1. Verificar archivo en ios/Runner/
2. En Xcode: Add to target "Runner"
3. Clean build folder
```

### **"Pod install failed"**
```bash
SOLUCIÓN:
cd ios
pod deintegrate
pod install --repo-update
```

---

## ✅ CHECKLIST FINAL

```
🔥 FIREBASE:
☐ App iOS creada en Firebase Console
☐ Bundle ID: com.miproveedor.app
☐ GoogleService-Info.plist descargado
☐ Archivo colocado en ios/Runner/

📱 FLUTTER:
☐ flutter doctor sin errores iOS
☐ pod install ejecutado
☐ Bundle ID configurado en Xcode

🧪 TESTING:
☐ Dispositivo iOS conectado
☐ flutter devices muestra device
☐ flutter run -d ios funciona
```

---

## 🎯 RESULTADO ESPERADO

Después de estos pasos:
- ✅ **App se instala en iPhone/iPad**
- ✅ **Firebase funciona (login, Firestore)**
- ✅ **Todas las funcionalidades disponibles**
- ✅ **Lista para demos y testing**

---

## 🆘 SI NECESITAS MAC

### **OPCIONES SIN TENER MAC:**

1. **🌥️ MacinCloud**: Alquiler Mac en la nube
   - $20/mes por Mac virtual
   - Acceso completo a Xcode

2. **🔧 GitHub Actions**: Build automático
   - Gratis para proyectos públicos
   - Build .ipa automáticamente

3. **📱 Codemagic**: CI/CD especializado Flutter
   - 500 minutos gratis/mes
   - Build iOS sin Mac

4. **👥 Colaboración**: 
   - Buscar desarrollador iOS local
   - Solo para setup inicial

---

## 📞 SOPORTE

Si tienes problemas:
1. 📋 Ejecutar `flutter doctor -v`
2. 📱 Verificar dispositivo con `flutter devices`
3. 🔍 Revisar logs con `flutter logs`

**¿Tienes Mac o necesitas alternativas para build iOS?**
