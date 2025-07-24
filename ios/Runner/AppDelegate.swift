import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // 🔥 INICIALIZAR FIREBASE PRIMERO
    FirebaseApp.configure()
    
    // 🔔 CONFIGURAR NOTIFICACIONES PUSH
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    // 📱 REGISTRAR PARA NOTIFICACIONES REMOTAS
    application.registerForRemoteNotifications()
    
    // 🔥 CONFIGURAR FIREBASE MESSAGING
    Messaging.messaging().delegate = self
    
    // 🎨 CONFIGURAR FLUTTER ENGINE
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // 🔧 REGISTRAR PLUGINS DE FLUTTER
    GeneratedPluginRegistrant.register(with: self)
    
    // ✅ LLAMAR AL SUPER
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // 🔔 MANEJAR NOTIFICACIONES RECIBIDAS
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any]
  ) {
    // Manejar notificación en segundo plano
    print("📱 Notificación recibida: \(userInfo)")
  }
  
  // 🔔 MANEJAR NOTIFICACIONES CON COMPLETION HANDLER
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    print("📱 Notificación con completion handler: \(userInfo)")
    completionHandler(.newData)
  }
  
  // 📱 TOKEN DE NOTIFICACIONES REGISTRADO
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("📱 Token registrado exitosamente")
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // ❌ ERROR AL REGISTRAR NOTIFICACIONES
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("❌ Error registrando notificaciones: \(error)")
  }
}

// 🔥 EXTENSIÓN PARA FIREBASE MESSAGING
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("🔥 Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}

// 🔔 EXTENSIÓN PARA NOTIFICACIONES
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Mostrar notificación cuando app está en primer plano
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("🔔 Notificación en primer plano: \(userInfo)")
    
    // Mostrar banner, sonido y badge
    if #available(iOS 14.0, *) {
      completionHandler([[.banner, .sound, .badge]])
    } else {
      completionHandler([[.alert, .sound, .badge]])
    }
  }
  
  // Manejar toque en notificación
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("👆 Usuario tocó notificación: \(userInfo)")
    
    completionHandler()
  }
}
