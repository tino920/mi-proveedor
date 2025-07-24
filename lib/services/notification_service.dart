import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Pedir permiso al usuario (necesario para iOS)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('¡Notificación recibida en primer plano!');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      // Aquí podrías mostrar un diálogo o una SnackBar si lo deseas
    });
  }

  // Obtiene el token único del dispositivo
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Guarda el token en el perfil del usuario en Firestore
  Future<void> saveTokenToDatabase(String userId) async {
    String? token = await getDeviceToken();
    if (token != null) {
      // Busca el documento del usuario en la colección 'users'
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Actualiza el documento con el nuevo token
      await userRef.set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge:true evita sobreescribir otros datos
    }
  }
}
