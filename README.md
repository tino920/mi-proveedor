# 🍽️ MiProveedor - Gestión Inteligente de Pedidos

> **Aplicación móvil profesional para gestión de pedidos a proveedores en restaurantes**  
> Desarrollado con Flutter y Firebase por **MobilePro**

## 🌟 Características Principales

- 🔐 **Autenticación segura** con Firebase Auth
- 👥 **Roles diferenciados**: Admin y Empleados  
- 📦 **Gestión completa** de productos y proveedores
- 📝 **Sistema de pedidos** con aprobación administrativa
- 🌍 **5 idiomas soportados**: Español, English, Català, Français, Italiano
- 📱 **Multiplataforma**: Android e iOS
- 🔔 **Notificaciones push** en tiempo real
- 👆 **Autenticación biométrica** (Face ID / Touch ID)
- 📊 **Reportes y estadísticas** en tiempo real
- 📄 **Generación de PDFs** automática

## 🛠️ Tecnologías Utilizadas

### **Frontend**
- **Flutter 3.16+** - Framework multiplataforma
- **Dart 3.1+** - Lenguaje de programación
- **Provider** - Gestión de estado
- **Material Design 3** - Sistema de diseño

### **Backend & Servicios**
- **Firebase Core** - Plataforma backend
- **Firebase Auth** - Autenticación
- **Cloud Firestore** - Base de datos NoSQL
- **Firebase Storage** - Almacenamiento de archivos
- **Firebase Messaging** - Notificaciones push
- **Firebase Analytics** - Analíticas

### **Funcionalidades Específicas**
- **Local Auth** - Autenticación biométrica
- **PDF Generation** - Generación de documentos
- **Excel Integration** - Import/Export datos
- **Multi-language** - Sistema i18n completo
- **Image Processing** - Compresión y optimización

## 📱 Plataformas Soportadas

| Plataforma | Estado | Versión Mínima |
|------------|---------|----------------|
| **Android** | ✅ **Funcional** | Android 6.0 (API 23) |
| **iOS** | ✅ **Listo** | iOS 12.0+ |
| **Web** | 🔄 **En desarrollo** | Chrome 80+ |

## 🌍 Idiomas Soportados

- 🇪🇸 **Español** (Principal)
- 🇺🇸 **English** 
- 🏴󠁥󠁳󠁣󠁴󠁿 **Català**
- 🇫🇷 **Français**
- 🇮🇹 **Italiano**

## 🚀 Instalación y Configuración

### **Prerrequisitos**
```bash
Flutter SDK 3.16+
Dart SDK 3.1+
Android Studio / VS Code
Firebase CLI
Git
```

### **Instalación**
```bash
# 1. Clonar repositorio
git clone https://github.com/TU_USUARIO/mi-proveedor.git
cd mi-proveedor

# 2. Instalar dependencias
flutter pub get

# 3. Configurar Firebase
# - Crear proyecto en Firebase Console
# - Añadir apps Android/iOS  
# - Descargar archivos de configuración

# 4. Ejecutar
flutter run
```

## 📋 Scripts Disponibles

### **🪟 Windows**
- `PREPARAR_PROYECTO_IOS.bat` - Preparar para desarrollo iOS
- `ARREGLAR_DEPENDENCIAS.bat` - Solucionar problemas dependencias
- `SUBIR_A_GITHUB.bat` - Subir proyecto a GitHub automáticamente

### **🍎 macOS/Linux**  
- `ios/flutter_ios_setup.sh` - Setup completo iOS con Mac

## 🏗️ Arquitectura del Proyecto

```
lib/
├── core/                    # Funcionalidades core
│   ├── auth/               # Autenticación
│   ├── theme/              # Temas y estilos
│   └── providers/          # Providers globales
├── features/               # Funcionalidades por módulos
│   ├── auth/              # Login/Registro
│   ├── dashboard/         # Pantallas principales
│   ├── suppliers/         # Gestión proveedores
│   ├── products/          # Gestión productos
│   ├── orders/            # Sistema de pedidos  
│   ├── employees/         # Gestión empleados
│   └── settings/          # Configuraciones
├── shared/                # Widgets compartidos
├── services/              # Servicios externos
└── generated/             # Archivos auto-generados
```

## 🔧 Configuración Firebase

### **1. Crear Proyecto Firebase**
1. Ir a [Firebase Console](https://console.firebase.google.com/)
2. Crear nuevo proyecto: "mi-proveedor"
3. Habilitar Google Analytics (opcional)

### **2. Configurar Authentication**
- Habilitar Email/Password
- Configurar dominios autorizados

### **3. Configurar Firestore**
- Crear base de datos en modo producción
- Importar reglas desde `firestore.rules`

### **4. Configurar Storage**  
- Habilitar Firebase Storage
- Configurar reglas de seguridad

## 🚀 Deployment

### **📱 Android**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (Google Play)
flutter build appbundle --release
```

### **🍎 iOS** 
```bash
# Con Mac/Xcode
flutter build ios --release

# Sin Mac (GitHub Actions)
# El workflow está configurado automáticamente
```

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de integración  
flutter test integration_test/

# Análisis de código
flutter analyze
```

## 🤝 Contribución

1. Fork del proyecto
2. Crear rama feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit cambios (`git commit -am 'Add nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👨‍💻 Desarrollado por

**MobilePro** - Desarrollador Senior Mobile  
Especialista en Flutter, Firebase y arquitecturas escalables

---

## 📞 Soporte

- 📧 **Email**: soporte@miproveedor.com
- 📱 **WhatsApp**: +34 900 123 456  
- 🐛 **Issues**: [GitHub Issues](../../issues)

---

<div align="center">

**⭐ Si te gusta el proyecto, dale una estrella ⭐**

Made with ❤️ by MobilePro

</div>
