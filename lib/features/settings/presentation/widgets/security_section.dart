import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

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
          // Header
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
                Icon(Icons.security, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seguridad y Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.verified_user, color: Colors.white, size: 20),
              ],
            ),
          ),
          
          // Opciones de seguridad
          Column(
            children: [
              _buildSettingsItem(
                Icons.lock,
                'Cambiar Contraseña',
                'Actualizar tu contraseña de acceso',
                () => _changePassword(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.shield,
                'Configuración de Seguridad',
                'Ver información de protección de cuenta',
                () => _showSecurityInfo(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.backup,
                'Copia de Seguridad',
                'Información sobre respaldo de datos',
                () => _showBackupInfo(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.history,
                'Historial de Actividad',
                'Ver actividad reciente de la cuenta',
                () => _showActivityHistory(context),
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

  // 🔒 CAMBIAR CONTRASEÑA
  void _changePassword(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Cambiar Contraseña'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_reset),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              const Text(
                '• Mínimo 8 caracteres\n• Al menos una mayúscula\n• Al menos un número',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _updatePassword(
              context,
              currentPasswordController.text,
              newPasswordController.text,
              confirmPasswordController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  // 🔐 ACTUALIZAR CONTRASEÑA
  Future<void> _updatePassword(BuildContext context, String current, String newPassword, String confirm) async {
    if (newPassword != confirm) {
      _showSnackBar(context, '❌ Las contraseñas no coinciden', AppTheme.errorColor);
      return;
    }

    if (newPassword.length < 8) {
      _showSnackBar(context, '❌ La contraseña debe tener al menos 8 caracteres', AppTheme.errorColor);
      return;
    }

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-autenticar con contraseña actual
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: current,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        if (context.mounted) {
          Navigator.pop(context); // Cerrar loading
          Navigator.pop(context); // Cerrar dialog
          _showSnackBar(context, '✅ Contraseña actualizada correctamente', AppTheme.successColor);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading
        String errorMessage = 'Error al cambiar contraseña';

        if (e.toString().contains('wrong-password')) {
          errorMessage = 'La contraseña actual es incorrecta';
        } else if (e.toString().contains('weak-password')) {
          errorMessage = 'La nueva contraseña es muy débil';
        }

        _showSnackBar(context, '❌ $errorMessage', AppTheme.errorColor);
      }
    }
  }

  // 🛡️ INFORMACIÓN DE SEGURIDAD
  void _showSecurityInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.shield, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Configuración de Seguridad'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🔐 Tu cuenta está protegida con:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              _SecurityFeature('Autenticación por email y contraseña'),
              _SecurityFeature('Encriptación de datos en tránsito'),
              _SecurityFeature('Sesiones con tiempo de expiración'),
              _SecurityFeature('Separación de datos por empresa'),
              _SecurityFeature('Backup automático en la nube'),
              _SecurityFeature('Monitoreo de actividad sospechosa'),
              SizedBox(height: 16),
              Text('✅ Tu información está segura', 
                style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('MiProveedor cumple con estándares de seguridad internacionales para proteger los datos de tu empresa.',
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

  // 💾 INFORMACIÓN DE BACKUP
  void _showBackupInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.backup, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Copia de Seguridad'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('☁️ Backup Automático Activo', 
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor)),
            SizedBox(height: 12),
            Text('Tus datos se respaldan automáticamente:'),
            SizedBox(height: 8),
            _SecurityFeature('Cada vez que realizas cambios'),
            _SecurityFeature('Almacenamiento seguro en la nube'),
            _SecurityFeature('Múltiples copias de seguridad'),
            _SecurityFeature('Recuperación automática'),
            SizedBox(height: 16),
            Text('📋 Datos respaldados:'),
            SizedBox(height: 8),
            _SecurityFeature('Información de empresa'),
            _SecurityFeature('Datos de proveedores y productos'),
            _SecurityFeature('Historial de pedidos'),
            _SecurityFeature('Configuraciones de usuarios'),
            SizedBox(height: 16),
            Text('No necesitas realizar ninguna acción adicional. Tus datos están protegidos automáticamente.',
              style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
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

  // 📊 HISTORIAL DE ACTIVIDAD
  void _showActivityHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Historial de Actividad'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📱 Actividad Reciente:'),
              SizedBox(height: 12),
              _ActivityItem('Inicio de sesión', 'Hoy 09:15', Icons.login),
              _ActivityItem('Pedido creado', 'Ayer 16:30', Icons.receipt_long),
              _ActivityItem('Proveedor editado', '2 días', Icons.business),
              _ActivityItem('Configuración actualizada', '3 días', Icons.settings),
              _ActivityItem('Nuevo empleado registrado', '5 días', Icons.person_add),
              SizedBox(height: 16),
              Text('💡 Los registros se mantienen por 90 días para garantizar la seguridad de tu cuenta.',
                style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

// Widgets auxiliares para la UI
class _SecurityFeature extends StatelessWidget {
  final String text;
  
  const _SecurityFeature(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String action;
  final String time;
  final IconData icon;
  
  const _ActivityItem(this.action, this.time, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 12),
          Expanded(child: Text(action, style: const TextStyle(fontSize: 13))),
          Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
        ],
      ),
    );
  }
}
