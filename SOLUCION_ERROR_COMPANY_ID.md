# 🔧 SOLUCIÓN: Error "No se pudo obtener el ID de la empresa"

## 🐛 Descripción del Problema

Este error aparece cuando un usuario (generalmente un empleado) intenta acceder a la aplicación pero no tiene un `companyId` asignado en su perfil de usuario.

### Causas comunes:
1. **Empleado sin empresa**: El empleado se registró pero no se vinculó correctamente a una empresa
2. **Código de empresa inválido**: Se usó un código que no existe o está mal escrito
3. **Empresa eliminada**: La empresa a la que estaba vinculado fue eliminada
4. **Error en el registro**: El proceso de registro no completó correctamente

## ✅ Soluciones

### Solución 1: Para EMPLEADOS

Si eres un **empleado** y ves este error:

1. **Cierra sesión** en la app
2. **Pide a tu administrador** el código de empresa correcto
   - El formato es: `RES-YYYY-XXXX` (ejemplo: `RES-2024-1234`)
3. **Regístrate nuevamente** como empleado usando el código correcto

### Solución 2: Para ADMINISTRADORES

Si eres un **administrador** y ves este error:

1. **Cierra sesión** en la app
2. **Registra una nueva empresa**:
   - Ve a la pantalla de registro
   - Selecciona la pestaña "Empresa"
   - Completa el formulario de registro
   - El sistema generará automáticamente un código de empresa
3. **Comparte el código** con tus empleados

### Solución 3: Verificar en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Firestore Database**
4. Busca la colección **`users`**
5. Encuentra tu usuario por email
6. Verifica que tenga el campo **`companyId`** con un valor válido

Si no tiene `companyId`:
- Los empleados deben registrarse con un código de empresa válido
- Los admins deben registrar primero la empresa

### Solución 4: Ejecutar script de diagnóstico

Ejecuta el archivo **`CORREGIR_COMPANY_ID.bat`** que:
1. Diagnosticará el problema
2. Mostrará información sobre tu cuenta
3. Te indicará los pasos específicos a seguir

## 🛠️ Cambios Aplicados al Código

He actualizado el archivo `employee_dashboard_screen.dart` para:

1. **Mejor manejo de errores**: Ahora muestra una pantalla informativa en lugar de solo un mensaje de error
2. **Opciones de acción**: Incluye botones para recargar datos o cerrar sesión
3. **Instrucciones claras**: Explica qué hacer para resolver el problema
4. **Diseño mejorado**: Interfaz más amigable y profesional

## 📝 Prevención Futura

Para evitar este problema en el futuro:

1. **Durante el registro de empleados**:
   - Asegúrate de tener el código de empresa correcto
   - Verifica que el código esté bien escrito (mayúsculas, guiones)
   - No uses espacios antes o después del código

2. **Como administrador**:
   - Guarda el código de empresa en un lugar seguro
   - Compártelo solo con empleados autorizados
   - Verifica regularmente que los empleados estén correctamente vinculados

3. **Validaciones mejoradas**:
   - El sistema ahora valida mejor los códigos de empresa
   - Muestra mensajes de error más claros
   - Previene registros incompletos

## 🚀 Próximos Pasos

1. **Reinicia la aplicación** después de aplicar las correcciones
2. **Intenta iniciar sesión** nuevamente
3. Si el problema persiste, **ejecuta el script de diagnóstico**
4. Como último recurso, **contacta soporte técnico** con los detalles del error

---

**¡Tu app RestauPedidos está lista para funcionar correctamente!** 🎉