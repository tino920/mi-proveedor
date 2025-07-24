import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'core/auth/auth_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/admin/admin_dashboard_screen.dart';
import 'features/dashboard/employee/employee_dashboard_screen.dart';
import 'features/suppliers/providers/suppliers_provider.dart';
import 'features/products/providers/products_provider.dart';
import 'features/orders/providers/orders_provider.dart';
import 'screens/firebase_error_screen.dart';
import 'screens/firebase_diagnostic_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase con manejo de errores
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('🔥 Firebase inicializado correctamente');
    print('📋 Project ID: ${Firebase.app().options.projectId}');
    print('🔑 API Key: ${Firebase.app().options.apiKey.substring(0, 15)}...');
  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
    // Continuar con la app, se maneja en AuthWrapper
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => RestauAuthProvider()),
        
        // Feature providers
        ChangeNotifierProvider(create: (_) => SuppliersProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        title: 'MiProveedor',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        home: const AuthWrapper(),
        // Añadir ruta para diagnóstico
        routes: {
          '/diagnostic': (context) => const FirebaseDiagnosticScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestauAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF6B73FF),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo de la app
                  const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MiProveedor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestión inteligente de pedidos',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 40),
                  
                  // Botón de diagnóstico para troubleshooting
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      children: [
                        const Text(
                          '¿Problemas para cargar?',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/diagnostic');
                          },
                          icon: const Icon(Icons.bug_report, size: 16),
                          label: const Text('Diagnóstico Firebase'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        if (authProvider.user == null) {
          return const LoginScreen();
        }
        
        // Verificar el rol del usuario
        if (authProvider.userRole == 'admin') {
          return const AdminDashboardScreen();
        } else {
          return const EmployeeDashboardScreen();
        }
      },
    );
  }
}
