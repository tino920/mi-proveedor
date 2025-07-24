// Importa los módulos necesarios
const {onDocumentUpdated, onDocumentCreated, onDocumentDeleted} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

// Inicializa la app de Firebase Admin
initializeApp();

// Establece la región para TODAS las funciones en este archivo.
setGlobalOptions({ region: "europe-west4" });

// ===================================================================================
// FUNCIÓN 1: Notifica cuando el estado 'isActive' de un usuario cambia.
// ===================================================================================
exports.sendUserStatusNotification = onDocumentUpdated("users/{userId}", async (event) => {
  const dataBefore = event.data.before.data();
  const dataAfter = event.data.after.data();
  if (dataBefore.isActive === dataAfter.isActive) return null;

  const userDeviceToken = dataAfter.fcmToken;
  if (!userDeviceToken) return null;

  const nuevoEstado = dataAfter.isActive;
  const messageBody = nuevoEstado ? "¡Tu cuenta ha sido activada!" : "Tu cuenta ha sido desactivada.";
  const message = { notification: { title: "Actualización de tu cuenta", body: messageBody }, token: userDeviceToken };

  try {
    await getMessaging().send(message);
    logger.log(`Notificación de estado enviada a ${event.params.userId}.`);
  } catch (error) {
    logger.error(`Error en F1 para ${event.params.userId}:`, error);
  }
});

// ===================================================================================
// FUNCIÓN 2: Notifica al empleado si su pedido es APROBADO o RECHAZADO.
// ===================================================================================
exports.handleOrderStatusChange = onDocumentUpdated("companies/{companyId}/orders/{orderId}", async (event) => {
  const dataBefore = event.data.before.data();
  const dataAfter = event.data.after.data();
  if (dataBefore.status === dataAfter.status) return null;

  const employeeId = dataAfter.employeeId;
  if (!employeeId) return null;

  const db = getFirestore();
  const userDoc = await db.collection('users').doc(employeeId).get();
  if (!userDoc.exists) return null;

  const userDeviceToken = userDoc.data().fcmToken;
  if (!userDeviceToken) return null;

  let notificationTitle = "";
  let notificationBody = "";
  const newStatus = dataAfter.status;

  if (newStatus === 'approved') {
    notificationTitle = "¡Pedido Aprobado!";
    notificationBody = `Tu pedido ha sido aprobado.`;
  } else if (newStatus === 'rejected') {
    notificationTitle = "Pedido Rechazado";
    notificationBody = `Tu pedido ha sido rechazado.`;
  } else {
    return null;
  }

  const message = {
  notification: { title: notificationTitle, body: notificationBody },
  token: userDeviceToken };
  android: {
      priority: "high",
    },
    apns: {
      headers: {
        "apns-priority": "10",
      },
    },
  };
  try {
    await getMessaging().send(message);
    logger.log(`Notificación de pedido ('${newStatus}') enviada a ${employeeId}.`);
  } catch (error) {
    logger.error(`Error en F2 para ${employeeId}:`, error);
  }
});

// ===================================================================================
// FUNCIÓN 3 (CORREGIDA): Notifica a TODOS los ADMINS cuando llega un NUEVO pedido.
// ===================================================================================
exports.sendNewOrderNotificationToAdmins = onDocumentCreated("companies/{companyId}/orders/{orderId}", async (event) => {
  const companyId = event.params.companyId;
  const orderData = event.data.data();

  const db = getFirestore();
  const companyDoc = await db.collection('companies').doc(companyId).get();
  if (!companyDoc.exists) {
    logger.log(`Compañía ${companyId} no encontrada.`);
    return null;
  }

  // 🔥 CAMBIO: Leer el array 'admins' en lugar de 'adminId'
  const adminIds = companyDoc.data().admins;
  if (!adminIds || !Array.isArray(adminIds) || adminIds.length === 0) {
    logger.log(`No se encontraron administradores para la compañía ${companyId}.`);
    return null;
  }

  // Obtener los tokens de todos los administradores
  const tokenPromises = adminIds.map(id => db.collection('users').doc(id).get());
  const adminDocs = await Promise.all(tokenPromises);

  const adminTokens = adminDocs
    .map(doc => doc.exists ? doc.data().fcmToken : null)
    .filter(token => token); // Filtra los tokens nulos o inválidos

  if (adminTokens.length === 0) {
    logger.log("Ninguno de los administradores tiene un token FCM válido.");
    return null;
  }

  const employeeName = orderData.employeeName || 'Un empleado';
  const message = {
    notification: {
      title: "Nuevo Pedido para Aprobar",
      body: `${employeeName} ha enviado un nuevo pedido.`
    },
    tokens: adminTokens, // 🔥 CAMBIO: Usar 'tokens' para enviar a múltiples dispositivos
  };

  try {
    // Usar 'sendEachForMulticast' es más robusto para enviar a múltiples tokens
    const response = await getMessaging().sendEachForMulticast(message);
    logger.log(`Notificación de nuevo pedido enviada a ${response.successCount} de ${adminTokens.length} administradores.`);
  } catch (error) {
    logger.error(`Error en F3 para la compañía ${companyId}:`, error);
  }
});

// ===================================================================================
// FUNCIÓN 4 (NUEVA): Limpia los productos cuando un proveedor es eliminado.
// ===================================================================================
exports.onDeleteSupplierCleanup = onDocumentDeleted("companies/{companyId}/suppliers/{supplierId}", async (event) => {
  const companyId = event.params.companyId;
  const supplierId = event.params.supplierId;

  logger.log(`Proveedor ${supplierId} de la compañía ${companyId} ha sido eliminado. Iniciando limpieza de productos.`);

  const db = getFirestore();

  // 1. Buscar todos los productos que pertenecen al proveedor eliminado.
  const productsQuery = db.collection('companies').doc(companyId).collection('products')
    .where('supplierId', '==', supplierId);

  const productSnapshots = await productsQuery.get();

  if (productSnapshots.empty) {
    logger.log("No se encontraron productos para este proveedor. Limpieza completada.");
    return null;
  }

  // 2. Usar un WriteBatch para eliminar todos los productos encontrados en una sola operación.
  const batch = db.batch();
  productSnapshots.docs.forEach(doc => {
    batch.delete(doc.ref);
  });

  // 3. Ejecutar el borrado en lote.
  await batch.commit();

  logger.log(`Limpieza completada: Se han eliminado ${productSnapshots.size} productos del proveedor ${supplierId}.`);

  return null;
});
