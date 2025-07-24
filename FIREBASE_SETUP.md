# 🔧 CONFIGURACIÓN DE FIREBASE PARA RESTAU PEDIDOS

## ⚠️ PROBLEMA IDENTIFICADO

El problema principal por el que **no se pueden añadir productos** es que **Firebase no está configurado correctamente**. He creado archivos temporales para que puedas probar la funcionalidad, pero necesitas configurar tu propio proyecto de Firebase.

## 🚀 SOLUCIÓN COMPLETA

### 1. **Crear Proyecto Firebase**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado "restau-pedidos"
3. Habilita los siguientes servicios:
   - **Authentication** (Email/Password)
   - **Cloud Firestore** 
   - **Storage**
   - **Cloud Functions** (opcional)

### 2. **Configurar Flutter con Firebase**

```bash
# Instalar FlutterFire CLI
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Inicializar Firebase en tu proyecto
flutterfire configure --project=tu-proyecto-firebase
```

### 3. **Reglas de Firestore Necesarias**

Copia estas reglas en Firebase Console > Firestore > Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso a empresas solo a sus miembros
    match /companies/{companyId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.members;
      
      // Productos - solo admin puede escribir, todos pueden leer
      match /products/{productId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.members;
        allow write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.admins;
      }
      
      // Proveedores - solo admin puede escribir
      match /suppliers/{supplierId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.members;
        allow write: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.admins;
      }
      
      // Pedidos - empleados pueden crear, admin puede modificar
      match /orders/{orderId} {
        allow read: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.members;
        allow create: if request.auth != null && 
          request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.members;
        allow update: if request.auth != null && 
          (request.auth.uid == resource.data.employeeId || 
           request.auth.uid in get(/databases/$(database)/documents/companies/$(companyId)).data.admins);
      }
    }
  }
}
```

### 4. **Reglas de Storage**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /companies/{companyId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        request.auth.uid in firestore.get(/databases/(default)/documents/companies/$(companyId)).data.members;
    }
  }
}
```

### 5. **Configurar Authentication**

En Firebase Console > Authentication > Sign-in method:
- ✅ Habilitar **Email/Password**
- ✅ Configurar dominios autorizados

## 🧪 TESTING TEMPORAL

Mientras configuras Firebase, puedes usar el archivo de prueba que creé:

```dart
// Importa en tu main.dart para testing
import 'test_files/test_products_screen.dart';

// Añade este botón temporal en tu dashboard
FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => TestProductsScreen()),
  ),
  child: Icon(Icons.bug_report),
)
```

## ⚡ CORRECCIONES REALIZADAS

### ✅ **Errores corregidos:**

1. **Null-safety en order_stats_overview.dart**
2. **Falta firebase_options.dart** - Archivo creado
3. **Configuración de Firebase en main.dart** - Actualizada
4. **Inicialización de variables en AddProductDialog** - Corregida

### ✅ **Archivos de prueba creados:**

- `test_files/test_products.dart` - Tests de funcionalidad
- `test_files/test_products_screen.dart` - Pantalla de prueba
- `firebase_options.dart` - Configuración Firebase temporal

## 🎯 PRÓXIMOS PASOS

1. **Configurar tu proyecto Firebase real** siguiendo los pasos arriba
2. **Reemplazar la configuración temporal** con la real
3. **Probar la funcionalidad** de añadir productos
4. **Configurar la importación Excel** una vez que productos funcione

## 🆘 SUPPORT

Si sigues teniendo problemas después de configurar Firebase:

1. Verifica que estés **autenticado** como admin
2. Comprueba las **reglas de Firestore** en la consola
3. Mira los **logs de error** en la consola del navegador/dispositivo
4. Usa el **TestProductsScreen** para diagnosticar problemas

¡Una vez configurado Firebase correctamente, podrás añadir productos tanto manualmente como por Excel! 🚀
