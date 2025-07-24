import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/auth/auth_provider.dart';
import '../shared/widgets/debug_widgets.dart';
import '../test_files/test_products_screen.dart';

class FirebaseErrorScreen extends StatelessWidget {
  final String? error;
  
  const FirebaseErrorScreen({
    super.key,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6B73FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de error
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.cloud_off,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título
              const Text(
                'Error de Conexión',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Descripción
              const Text(
                'No se pudo conectar con Firebase.\nVerifica tu configuración.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Error específico (si existe)
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Error técnico:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
              
              // Botones de acción
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _retryConnection(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6B73FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reintentar Conexión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showInstructions(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ver Instrucciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const TestProductsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.science),
                      label: const Text('Modo Desarrollo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Información adicional
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Posibles soluciones:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• Configura Firebase correctamente',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '• Verifica tu conexión a internet',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '• Revisa firebase_options.dart',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              '• Consulta FIREBASE_SETUP.md',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _retryConnection(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
    
    // Intentar reconectar
    authProvider.checkFirebaseConnection().then((connected) {
      Navigator.of(context).pop(); // Cerrar loading
      
      if (connected) {
        // Reinicializar AuthProvider
        authProvider.forceStopLoading();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexión restablecida!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo conectar. Verifica tu configuración.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FirebaseInstructionsDialog(),
    );
  }
}
