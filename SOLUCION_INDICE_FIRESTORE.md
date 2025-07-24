🔥 SOLUCIÓN PARA ERROR DE ÍNDICE FIRESTORE

## 🚨 ERROR RECIBIDO:
```
Error: [cloud_firestore/failed-precondition] The query requires an index.
```

## ✅ SOLUCIÓN RÁPIDA APLICADA:
- He removido temporalmente el `.orderBy('name')` de la consulta
- Ahora el ordenamiento se hace en el código de la app
- Los proveedores deberían cargar normalmente

## 🔗 LINKS PARA CREAR ÍNDICE (Si prefieres usar orderBy en Firestore):

### 📋 Opción 1: Acceso directo a Firebase Console
https://console.firebase.google.com/project/[TU_PROJECT_ID]/firestore/indexes

### 📋 Opción 2: Acceso manual
1. Ve a https://console.firebase.google.com
2. Selecciona tu proyecto
3. Ve a "Firestore Database"
4. Ve a la pestaña "Indexes"
5. Haz clic en "Create Index"
6. Configura:
   - Collection ID: `suppliers`
   - Field: `name` (Ascending)
   - Field: `__name__` (Ascending)

### 📋 Opción 3: Crear índice automáticamente
1. Ve a Firebase Console
2. Ve a "Firestore Database" > "Indexes"
3. Debería aparecer una sugerencia automática para crear el índice
4. Haz clic en "Create Index"

## 🔧 PARA VOLVER A USAR ORDERBY EN FIRESTORE:

Una vez creado el índice, puedes descomentar la línea en:
`lib/features/suppliers/providers/suppliers_provider.dart`

```dart
// Línea 30 - Descomenta esta línea:
.orderBy('name')
```

## 🎯 ESTADO ACTUAL:
- ✅ Los proveedores se cargan sin error
- ✅ Se ordenan por nombre en el código
- ✅ Funcionalidad completa disponible
- ⚠️ Usar índice sería más eficiente para grandes cantidades de datos

## 📊 CUANDO CREAR EL ÍNDICE:
- Si tienes más de 100 proveedores
- Si quieres mejor performance
- Si planeas agregar más filtros complejos

Por ahora, la app debería funcionar perfectamente sin el índice.
