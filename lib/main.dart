import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// 🌍 SISTEMA DE LOCALIZACIÓN COMPLETO - 5 IDIOMAS
import 'package:mi_proveedor/generated/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/admin/admin_dashboard_screen.dart';
import 'features/dashboard/employee/employee_dashboard_screen.dart';
import 'features/suppliers/providers/suppliers_provider.dart';
import 'features/products/providers/products_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'features/employees/providers/employees_provider.dart';
import 'core/providers/ui_settings_provider.dart';
import 'core/providers/localization_provider.dart';
import 'services/notification_service.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mi_proveedor/core/providers/admin_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    await NotificationService().initialize();
    print('🚀 Firebase, Caché y Notificaciones inicializados correctamente');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🌍 LOCALIZACIÓN - DEBE IR PRIMERO PARA INICIALIZAR TEMPRANO
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        
        // 🔐 AUTENTICACIÓN  
        ChangeNotifierProvider(create: (_) => RestauAuthProvider()),
        
        // 🎨 CONFIGURACIÓN UI
        ChangeNotifierProvider(create: (_) => UISettingsProvider()),

        // 🏢 CONFIGURACIÓN DE ADMINISTRADOR
        ChangeNotifierProxyProvider<RestauAuthProvider, AdminSettingsProvider>(
          create: (context) => AdminSettingsProvider(context.read<RestauAuthProvider>()),
          update: (context, auth, previousProvider) {
            if (previousProvider == null) return AdminSettingsProvider(auth);
            previousProvider.updateAuthProvider(auth);
            return previousProvider;
          },
        ),

        // 👥 GESTIÓN DE EMPLEADOS
        ChangeNotifierProxyProvider<RestauAuthProvider, EmployeesProvider>(
          create: (context) => EmployeesProvider(context.read<RestauAuthProvider>()),
          update: (context, auth, previousProvider) {
            if (previousProvider == null) return EmployeesProvider(auth);
            previousProvider.updateAuthProvider(auth);
            if (auth.companyId != null && previousProvider.employees.isEmpty && !previousProvider.isLoading) {
              previousProvider.loadEmployees();
            }
            return previousProvider;
          },
        ),
        
        // 📦 OTROS PROVIDERS
        ChangeNotifierProvider(create: (_) => SuppliersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 🌍 Inicializar sistema de localización cuando la app arranque
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocalizationProvider>().initialize();
      context.read<UISettingsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiSettings = context.watch<UISettingsProvider>();
    final localization = context.watch<LocalizationProvider>();

    return MaterialApp(
      key: ValueKey(localization.currentLanguageCode),  // ← AÑADE ESTO

      title: 'MiProveedor 🌍 5 Idiomas Profesional',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: uiSettings.themeMode,
      
      // 🌍 CONFIGURACIÓN COMPLETA DE LOCALIZACIÓN
      locale: localization.currentLocale,
      
      // 📋 DELEGADOS DE LOCALIZACIÓN COMPLETOS
      localizationsDelegates: const [
        AppLocalizations.delegate,                // ← TU SISTEMA PERSONALIZADO
        GlobalMaterialLocalizations.delegate,     // ← Material Design
        GlobalWidgetsLocalizations.delegate,      // ← Widgets básicos
        GlobalCupertinoLocalizations.delegate,    // ← iOS Style
      ],
      
      // 🇪🇸🇺🇸🏴󠁥󠁳󠁣󠁴󠁿🇫🇷🇮🇹 SOPORTE COMPLETO 5 IDIOMAS
      supportedLocales: const [
        Locale('es', 'ES'), // 🇪🇸 Español
        Locale('en', 'US'), // 🇺🇸 English
        Locale('ca', 'ES'), // 🏴󠁥󠁳󠁣󠁴󠁿 Català
        Locale('fr', 'FR'), // 🇫🇷 Français
        Locale('it', 'IT'), // 🇮🇹 Italiano
      ],
      
      debugShowCheckedModeBanner: false,
      
      // 🔍 RESOLUCIÓN DE LOCALE INTELIGENTE
      localeResolutionCallback: (locale, supportedLocales) {
        // Si el idioma del dispositivo está soportado, úsalo
        if (locale != null) {
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
        }
        // Fallback a español
        return const Locale('es', 'ES');
      },
      
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<RestauAuthProvider>();
    final localization = context.watch<LocalizationProvider>();

    if (authProvider.isLoading || !localization.isInitialized) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF6B73FF), Color(0xFF129793)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                Text(
                  'MiProveedor',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gestión inteligente de pedidos',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 16),
                // 🌍 INDICADOR DE IDIOMA ACTUAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.language, color: Colors.white70, size: 16),
                    SizedBox(width: 4),
                    Text(
                      '5 idiomas soportados',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'Inicializando sistema multiidioma...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authProvider.user == null) {
      return const LoginScreen();
    }

    if (authProvider.userRole == 'admin') {
      return const AdminDashboardScreen();
    } else {
      return const EmployeeDashboardScreen();
    }
  }
}

/// 🎯 EXTENSION PARA ACCESO RÁPIDO A TRADUCCIONES
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      throw Exception('❌ AppLocalizations no encontrado. ¿Sistema de localización inicializado?');
    }
    return localizations;
  }
  
  // Método de respaldo con fallback
  String tr(String key, [String? fallback]) {
    try {
      return l10n.toString();
    } catch (e) {
      return fallback ?? key;
    }
  }
  
  // Acceso rápido al idioma actual
  String get currentLanguage {
    final localization = watch<LocalizationProvider>();
    return localization.currentLanguageCode;
  }
  
  // Acceso rápido al nombre del idioma actual
  String get currentLanguageName {
    final localization = watch<LocalizationProvider>();
    return localization.currentLanguageName;
  }
}
