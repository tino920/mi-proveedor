import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../test_files/test_products_screen.dart';

class DebugTestButton extends StatelessWidget {
  const DebugTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Solo mostrar en modo debug
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 80,
      right: 16,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.orange,
        heroTag: "debug_test_button",
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TestProductsScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.bug_report,
          color: Colors.white,
        ),
      ),
    );
  }
}

// Widget para mostrar información de Firebase status
class FirebaseStatusWidget extends StatelessWidget {
  const FirebaseStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Configuración Firebase Requerida',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Para poder añadir productos, necesitas configurar tu proyecto Firebase. '
            'Revisa el archivo FIREBASE_SETUP.md para instrucciones detalladas.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TestProductsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.science),
                label: const Text('Test Productos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const FirebaseInstructionsDialog(),
                  );
                },
                icon: const Icon(Icons.info),
                label: const Text('Ver Instrucciones'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FirebaseInstructionsDialog extends StatelessWidget {
  const FirebaseInstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Firebase'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para que funcione la creación de productos, necesitas:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStep('1.', 'Crear proyecto en Firebase Console'),
            _buildStep('2.', 'Habilitar Authentication (Email/Password)'),
            _buildStep('3.', 'Habilitar Cloud Firestore'),
            _buildStep('4.', 'Habilitar Storage'),
            _buildStep('5.', 'Configurar reglas de seguridad'),
            _buildStep('6.', 'Reemplazar firebase_options.dart con tu configuración'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💡 Revisa el archivo FIREBASE_SETUP.md para instrucciones detalladas paso a paso.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
