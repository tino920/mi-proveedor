🔍 INSTRUCCIONES PARA DIAGNOSTICAR EL PROBLEMA DE PROVEEDORES

📋 PASOS A SEGUIR:

1. APLICAR REGLAS DE FIRESTORE:
   - Ve a Firebase Console (https://console.firebase.google.com)
   - Selecciona tu proyecto
   - Ve a "Firestore Database"
   - Ve a la pestaña "Reglas"
   - Copia y pega las reglas del archivo `firestore.rules`
   - Publica las reglas

2. EJECUTAR LA APP:
   ```bash
   flutter run
   ```

3. PROBAR LA PANTALLA DE DEBUG:
   - Inicia sesión como admin
   - Ve a la pestaña "Proveedores" (segunda pestaña)
   - Verás la pantalla de debug con información detallada

4. REVISAR INFORMACIÓN DE DEBUG:
   - En la parte superior verás información básica (CompanyId, User, Role)
   - En el medio verás el estado detallado del stream
   - Puedes pulsar "Test Firestore Direct" para probar conexión directa

5. ACCIONES DISPONIBLES:
   - "Test Firestore Direct": Prueba la conexión a Firestore sin el stream
   - "Añadir Proveedor": Crea un nuevo proveedor para testing
   - La pantalla muestra en tiempo real el estado del StreamBuilder

📊 QUÉ BUSCAR:

✅ CASO EXITOSO:
   - ConnectionState: active
   - HasError: false
   - HasData: true
   - Data length: número > 0
   - Lista de proveedores visible

❌ POSIBLES PROBLEMAS:
   - ConnectionState: waiting (se queda cargando)
   - HasError: true (error específico mostrado)
   - HasData: false (stream funciona pero sin datos)
   - Error de permisos de Firestore

🔧 SOLUCIONES SEGÚN EL PROBLEMA:

A) SI SE QUEDA EN "waiting":
   - Problema de reglas de Firestore
   - Problema de autenticación
   - CompanyId no válido

B) SI MUESTRA ERROR:
   - Revisar el error específico
   - Verificar permisos de Firestore
   - Comprobar estructura de datos

C) SI STREAM FUNCIONA PERO SIN DATOS:
   - No hay proveedores creados
   - Problema en la consulta
   - CompanyId incorrecto

📝 INFORMACIÓN A COMPARTIR:
Después de ejecutar, comparte:
1. El contenido del panel DEBUG INFO (parte superior negra)
2. El estado del STREAM STATE (tarjeta del medio)
3. Cualquier error que aparezca
4. El resultado del botón "Test Firestore Direct"

🎯 OBJETIVO:
Identificar exactamente dónde está el problema:
- ¿Es un problema de Firestore rules?
- ¿Es un problema de autenticación?
- ¿Es un problema de parsing de datos?
- ¿Es un problema de companyId?

Una vez identificado el problema, podremos crear la solución específica.
