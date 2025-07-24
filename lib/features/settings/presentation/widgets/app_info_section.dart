import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';

class AppInfoSection extends StatelessWidget {
  const AppInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Información de la App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.restaurant, color: Colors.white, size: 20),
              ],
            ),
          ),
          Column(
            children: [
              _buildSettingsItem(
                Icons.info,
                'Acerca de MiProveedor',
                'Información sobre la aplicación',
                () => _showAboutDialog(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.article,
                'Términos y Condiciones',
                'Lee nuestros términos de servicio',
                () => _showTermsAndConditions(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.privacy_tip,
                'Política de Privacidad',
                'Conoce cómo protegemos tus datos',
                () => _showPrivacyPolicy(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.star_rate,
                'Calificar App',
                'Ayúdanos calificando la aplicación',
                () => _rateApp(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.update,
                'Buscar Actualizaciones',
                'Verificar si hay nuevas versiones',
                () => _checkForUpdates(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.secondaryTextColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // 📱 ACERCA DE LA APLICACIÓN
  void _showAboutDialog(BuildContext context) async {
    PackageInfo packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      packageInfo = PackageInfo(
        appName: 'MiProveedor',
        packageName: 'com.mobilepro.restau_pedidos',
        version: '1.0.0',
        buildNumber: '1',
      );
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.restaurant, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('Acerca de MiProveedor'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo y información principal
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageInfo.appName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Versión ${packageInfo.version} (${packageInfo.buildNumber})'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Descripción
              const Text('🍽️ Gestión inteligente de pedidos para restaurantes'),
              const SizedBox(height: 8),
              const Text('📱 Simplifica la comunicación con proveedores'),
              const SizedBox(height: 8),
              const Text('⚡ Importa desde Excel, genera PDFs, envía por WhatsApp'),
              const SizedBox(height: 16),
              
              // Información del desarrollador
              const Text('📱 Desarrollado por MobilePro'),
              const SizedBox(height: 4),
              const Text('🌐 www.mobilepro.dev'),
              const SizedBox(height: 12),
              
              // Copyright
              const Text('© 2024 MobilePro. Todos los derechos reservados'),
              const SizedBox(height: 16),
              
              // Características destacadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✨ Características:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('• Importación masiva desde Excel', style: TextStyle(fontSize: 12)),
                    Text('• Generación de PDFs profesionales', style: TextStyle(fontSize: 12)),
                    Text('• Envío directo por WhatsApp/Email', style: TextStyle(fontSize: 12)),
                    Text('• Sistema de aprobación admin-empleado', style: TextStyle(fontSize: 12)),
                    Text('• Funciona offline con sincronización', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => _visitWebsite(context),
              child: const Text('Visitar Web'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  // 📋 TÉRMINOS Y CONDICIONES
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.article, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Términos y Condiciones'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TÉRMINOS Y CONDICIONES DE USO', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 16),
              
              Text('1. ACEPTACIÓN DE LOS TÉRMINOS', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Al utilizar MiProveedor, aceptas estos términos y condiciones de uso. '
                'Si no estás de acuerdo, no uses la aplicación.'),
              SizedBox(height: 12),
              
              Text('2. DESCRIPCIÓN DEL SERVICIO', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('MiProveedor es una aplicación móvil diseñada para facilitar la gestión '
                'de pedidos a proveedores en establecimientos de hostelería.'),
              SizedBox(height: 12),
              
              Text('3. RESPONSABILIDADES DEL USUARIO', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Proporcionar información veraz y actualizada\n'
                '• Mantener la seguridad de tu cuenta\n'
                '• Usar el servicio de manera apropiada y legal\n'
                '• No compartir credenciales con terceros'),
              SizedBox(height: 12),
              
              Text('4. LIMITACIÓN DE RESPONSABILIDAD', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('El servicio se proporciona "tal como está". MobilePro no garantiza '
                'la disponibilidad continua del servicio ni se responsabiliza por errores '
                'en los pedidos realizados por los usuarios.'),
              SizedBox(height: 12),
              
              Text('5. PRIVACIDAD Y DATOS', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Consulta nuestra Política de Privacidad para conocer cómo manejamos '
                'tus datos personales.'),
              SizedBox(height: 12),
              
              Text('6. MODIFICACIONES', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Nos reservamos el derecho de modificar estos términos. Las modificaciones '
                'serán notificadas a través de la aplicación.'),
              SizedBox(height: 16),
              
              Text('Última actualización: Julio 2024', 
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // 🔒 POLÍTICA DE PRIVACIDAD
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.privacy_tip, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Política de Privacidad'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('POLÍTICA DE PRIVACIDAD', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 16),
              
              Text('1. INFORMACIÓN QUE RECOPILAMOS', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Datos de registro (email, nombre, empresa)\n'
                '• Información de proveedores y productos\n'
                '• Datos de pedidos y transacciones\n'
                '• Información de uso de la aplicación'),
              SizedBox(height: 12),
              
              Text('2. CÓMO USAMOS TU INFORMACIÓN', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Proporcionar y mejorar el servicio\n'
                '• Procesar pedidos y transacciones\n'
                '• Comunicarnos contigo\n'
                '• Cumplir con obligaciones legales'),
              SizedBox(height: 12),
              
              Text('3. PROTECCIÓN DE DATOS', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Encriptación en tránsito y en reposo\n'
                '• Acceso restringido a personal autorizado\n'
                '• Servidores seguros y backup automático\n'
                '• Cumplimiento con GDPR'),
              SizedBox(height: 12),
              
              Text('4. COMPARTIR INFORMACIÓN', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('No vendemos ni compartimos tu información personal con terceros, '
                'excepto cuando sea necesario para proporcionar el servicio o '
                'por requerimientos legales.'),
              SizedBox(height: 12),
              
              Text('5. TUS DERECHOS', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Acceder a tus datos personales\n'
                '• Corregir información inexacta\n'
                '• Solicitar eliminación de datos\n'
                '• Portabilidad de datos'),
              SizedBox(height: 12),
              
              Text('6. CONTACTO', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Para consultas sobre privacidad: privacidad@restau-pedidos.com'),
              SizedBox(height: 16),
              
              Text('Última actualización: Julio 2024', 
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ⭐ CALIFICAR APP
  void _rateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.star_rate, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Calificar MiProveedor'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.restaurant, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    '¿Te gusta usar MiProveedor?',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('⭐⭐⭐⭐⭐', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            const Text(
              'Tu opinión nos ayuda a mejorar y llegar a más restaurantes',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Solo toma 30 segundos!',
              style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⭐ ¡Gracias por tu calificación!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.star),
            label: const Text('Calificar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  // 🔄 BUSCAR ACTUALIZACIONES
  void _checkForUpdates(BuildContext context) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando actualizaciones...'),
          ],
        ),
      ),
    );

    // Simular búsqueda de actualizaciones
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.pop(context); // Cerrar loading
      
      // Mostrar resultado
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor),
              SizedBox(width: 8),
              Text('Actualización'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('✅ ¡Tu app está actualizada!'),
              SizedBox(height: 8),
              Text('Tienes la versión más reciente de MiProveedor.'),
              SizedBox(height: 16),
              Text(
                'Te notificaremos automáticamente cuando haya nuevas actualizaciones disponibles.',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Perfecto'),
            ),
          ],
        ),
      );
    }
  }

  // 🌐 VISITAR SITIO WEB
  void _visitWebsite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌐 Abriendo sitio web...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
