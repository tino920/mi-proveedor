import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/providers/localization_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import '../../../../core/providers/ui_settings_provider.dart';
import 'company_policies_screen.dart';
import "package:mi_proveedor/generated/l10n/app_localizations.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🏢 CONTROLADORES PARA EDITAR EMPRESA
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();

  // 🔔 CONFIGURACIONES DE NOTIFICACIONES
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _orderNotifications = true;
  bool _employeeNotifications = true;

  // 🎨 NUEVAS VARIABLES PARA PERSONALIZACIÓN
  String _selectedTheme = 'light'; // 'light', 'dark', 'system'
  String _selectedLanguage = 'es'; // 'es', 'en'
  double _textScale = 1.0; // 0.8, 1.0, 1.2, 1.4
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  void _checkAuthStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
    }
  }

  Future<void> _initializeUISettings() async {
    final uiSettings = context.read<UISettingsProvider>();
    await uiSettings.initialize();
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus(); // Ahora sí puede llamarla
    _loadNotificationSettings();
    _loadPersonalizationSettings(); // ← AÑADIR ESTA LÍNEA
    _checkBiometricAvailability();  // ← AÑADIR ESTA LÍNEA
    _initializeUISettings(); // ← Agregar esta línea
  }


  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final companyData = authProvider.companyData;
    final companyCode = companyData?['code'] ?? '';
    final isAdmin = authProvider.userRole == 'admin';

    return Consumer2<UISettingsProvider, LocalizationProvider>(  // ← Consumer2
      builder: (context, uiSettings, localizationProvider, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(uiSettings.textScale),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B73FF), Color(0xFF129793)], // ← Estos colores
              ),
            ),
      child: SafeArea(
        child: Column(
          children: [
            // 🎨 Header con gradiente
            _buildHeader(context),

            // 📱 Contenido con fondo blanco
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 10),

                    // 🏢 Información de la empresa (EDITABLE)
                    if (isAdmin) ...[
                      _buildCompanyInfoSection(companyData, companyCode),
                      const SizedBox(height: 20),
                    ],
                    
                    // 🔔 Configuración de Notificaciones
                    _buildNotificationsSection(),

                    const SizedBox(height: 20),

                    // 🎨 Sección de Apariencia
// 🎨 Sección de Apariencia
                    _buildAppearanceSection(uiSettings, localizationProvider),  // ← PASAR AMBOS PARÁMETROS
                    const SizedBox(height: 20),

                    // 🌐 Sección de Personalización
                    _buildPersonalizationSection(),

                    const SizedBox(height: 20),

                    // 🔐 Seguridad y Cuenta
                    _buildSecuritySection(uiSettings),

                    const SizedBox(height: 20),

                    // 👥 Gestión de Empleados (Solo Admin)
                    if (isAdmin) ...[
                      _buildEmployeeManagementSection(),
                      const SizedBox(height: 20),
                    ],

                    // 🆘 Ayuda y Soporte
                    _buildHelpSupportSection(),

                    const SizedBox(height: 20),

                    // ℹ️ Información de la App
                    _buildAppInfoSection(),

                    const SizedBox(height: 30),

                    // 🚪 Botón cerrar sesión
                    _buildLogoutButton(authProvider),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      );
      },
    );
  }

  // 📱 HEADER DE LA PANTALLA
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // ✅ CORRECTO - Quitar const
          Expanded(  // ← SIN const
            child: Text(
              AppLocalizations.of(context).settings,  // ← Import directo
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Botón de ayuda rápida
          IconButton(
            onPressed: () => _showHelpDialog(context),
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // 🏢 SECCIÓN DE INFORMACIÓN DE EMPRESA (EDITABLE)
  Widget _buildCompanyInfoSection(Map<String, dynamic>? companyData,
      String companyCode) {
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
            child: Row(
              children: [
                const Icon(Icons.business, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Información de la Empresa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editCompanyInfo(companyData),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                    'Nombre', companyData?['name'] ?? '', Icons.store),
                const SizedBox(height: 12),
                _buildInfoRow('Código', companyCode, Icons.qr_code),
                const SizedBox(height: 12),
                _buildInfoRow('Dirección', companyData?['address'] ?? '',
                    Icons.location_on),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Teléfono', companyData?['phone'] ?? '', Icons.phone),
                const SizedBox(height: 16),

                // Botón para compartir código de empresa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _shareCompanyCode(companyCode, companyData),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir Código de Empresa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔔 SECCIÓN DE NOTIFICACIONES
  Widget _buildNotificationsSection() {
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
                Icon(Icons.notifications, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Configuración de Notificaciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildNotificationSwitch(
                  'Notificaciones Push',
                  'Recibir notificaciones en el dispositivo',
                  Icons.notifications_active,
                  _pushNotifications,
                      (value) => setState(() => _pushNotifications = value),
                ),
                const Divider(),
                _buildNotificationSwitch(
                  'Notificaciones por Email',
                  'Recibir notificaciones por correo electrónico',
                  Icons.email,
                  _emailNotifications,
                      (value) => setState(() => _emailNotifications = value),
                ),
                const Divider(),
                _buildNotificationSwitch(
                  'Notificaciones de Pedidos',
                  'Alertas sobre nuevos pedidos y cambios de estado',
                  Icons.receipt_long,
                  _orderNotifications,
                      (value) => setState(() => _orderNotifications = value),
                ),
                const Divider(),
                _buildNotificationSwitch(
                  'Notificaciones de Empleados',
                  'Alertas sobre actividad de empleados',
                  Icons.people,
                  _employeeNotifications,
                      (value) => setState(() => _employeeNotifications = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔐 SECCIÓN DE SEGURIDAD PERSONAL (FUNCIONAL)
  Widget _buildSecuritySection(UISettingsProvider uiSettings) {
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
          _buildSettingsItem(
            Icons.lock,
            'Cambiar Contraseña',
            'Actualizar tu contraseña de acceso',
                () => _changePassword(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.security,
            'Configuración de Seguridad',
            'Gestionar opciones de seguridad',
                () => _showSecurityOptions(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.backup,
            'Copia de Seguridad',
            'Realizar backup de tus datos',
                () => _createBackup(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(  // ← Agregar este item
            Icons.fingerprint,
            'Autenticación Biométrica',
            uiSettings.biometricStatusText,
            () => _showBiometricOptions(uiSettings),
          ),
        ],
      ),
    );
  }

  // 👥 SECCIÓN DE GESTIÓN DE EMPLEADOS (Solo Admin)
  Widget _buildEmployeeManagementSection() {
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
                Icon(Icons.admin_panel_settings, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Gestión de Empleados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildSettingsItem(
                Icons.group_add,
                'Límites de Empleados',
                'Configurar límites de pedidos por empleado',
                    () => _configureEmployeeLimits(),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.rule,
                'Políticas de Empresa',
                'Definir reglas y políticas internas',
                    () => _configureCompanyPolicies(),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.analytics,
                'Reportes de Actividad',
                'Ver estadísticas de empleados',
                    () => _showEmployeeReports(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🆘 SECCIÓN DE AYUDA Y SOPORTE
  Widget _buildHelpSupportSection() {
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
          _buildSettingsItem(
            Icons.help_center,
            'Centro de Ayuda',
            'Preguntas frecuentes y tutoriales',
                () => _openHelpCenter(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.support_agent,
            'Contactar Soporte',
            'Obtener ayuda directa de nuestro equipo',
                () => _contactSupport(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.feedback,
            'Enviar Comentarios',
            'Comparte tu experiencia y sugerencias',
                () => _sendFeedback(),
          ),
        ],
      ),
    );
  }

  // ℹ️ SECCIÓN DE INFORMACIÓN DE LA APP
  Widget _buildAppInfoSection() {
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
          _buildSettingsItem(
            Icons.info,
            'Acerca de MiProveedor',
            'Información sobre la aplicación',
                () => _showAboutDialog(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.article,
            'Términos y Condiciones',
            'Lee nuestros términos de servicio',
                () => _showTermsAndConditions(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.privacy_tip,
            'Política de Privacidad',
            'Conoce cómo protegemos tus datos',
                () => _showPrivacyPolicy(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.star_rate,
            'Calificar App',
            'Ayúdanos calificando la aplicación',
                () => _rateApp(),
          ),
        ],
      ),
    );
  }

  // 🚪 BOTÓN DE CERRAR SESIÓN
  Widget _buildLogoutButton(RestauAuthProvider authProvider) {
    return GradientButton(
      text: 'Cerrar Sesión',
      icon: Icons.logout,
      onPressed: () => _showLogoutConfirmation(context, authProvider),
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      ),
    );
  }

  // 🔧 WIDGETS AUXILIARES
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'No configurado',
                style: TextStyle(
                  fontSize: 14,
                  color: value.isNotEmpty ? AppTheme.textColor : AppTheme
                      .secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch(String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
            _saveNotificationSettings();
          },
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle,
      VoidCallback onTap) {
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

  // 📱 FUNCIONES DE FUNCIONALIDAD

  // 🔧 Editar información de empresa
  void _editCompanyInfo(Map<String, dynamic>? companyData) {
    _companyNameController.text = companyData?['name'] ?? '';
    _companyAddressController.text = companyData?['address'] ?? '';
    _companyPhoneController.text = companyData?['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Editar Información de Empresa'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _companyNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la empresa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _companyAddressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _companyPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
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
                onPressed: () => _saveCompanyInfo(),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  // 💾 Guardar información de empresa
  Future<void> _saveCompanyInfo() async {
    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId != null) {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .update({
          'name': _companyNameController.text.trim(),
          'address': _companyAddressController.text.trim(),
          'phone': _companyPhoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Actualizar datos locales
        await authProvider.refreshUserData();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Información actualizada correctamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // 📤 Compartir código de empresa
  void _shareCompanyCode(String companyCode,
      Map<String, dynamic>? companyData) {
    final message = '''
¡Únete a nuestro equipo en MiProveedor!

🏢 Empresa: ${companyData?['name'] ?? 'Mi Empresa'}
🔑 Código: $companyCode

📱 Pasos para registrarte:
1. Descarga MiProveedor
2. Selecciona "Empleado" 
3. Introduce el código: $companyCode
4. Completa tu registro

¡Esperamos trabajar contigo! 🚀
''';

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Código de Empresa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    companyCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Comparte este código con tus empleados para que puedan registrarse en la app.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: companyCode));
                  _showSuccessSnackBar('📋 Código copiado al portapapeles');
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Share.share(message, subject: 'Invitación a MiProveedor');
                },
                icon: const Icon(Icons.share),
                label: const Text('Compartir'),
              ),
            ],
          ),
    );
  }

  // 🔐 Cambiar contraseña
  void _changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Cambiar Contraseña'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña actual',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
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
                onPressed: () =>
                    _updatePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    ),
                child: const Text('Cambiar'),
              ),
            ],
          ),
    );
  }

  // 🔄 Actualizar contraseña
  Future<void> _updatePassword(String current, String newPassword,
      String confirm) async {
    if (newPassword != confirm) {
      _showErrorSnackBar('❌ Las contraseñas no coinciden');
      return;
    }

    if (newPassword.length < 6) {
      _showErrorSnackBar('❌ La contraseña debe tener al menos 6 caracteres');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        _showErrorSnackBar('❌ Usuario no válido');
        return;
      }

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Re-autenticar con contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: current,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      // Cerrar loading
      if (mounted) Navigator.pop(context);

      // Cerrar diálogo de cambio
      if (mounted) Navigator.pop(context);

      // Mostrar éxito SIN logout
      if (mounted) {
        _showSuccessSnackBar('✅ Contraseña actualizada correctamente');
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (mounted) Navigator.pop(context);

      String errorMessage = '❌ Error al cambiar contraseña';

      if (e.toString().contains('wrong-password')) {
        errorMessage = '❌ Contraseña actual incorrecta';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = '❌ La nueva contraseña es muy débil';
      }

      if (mounted) {
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  // 🎨 SECCIÓN DE APARIENCIA (FUNCIONAL) - VERSIÓN CORREGIDA
  Widget _buildAppearanceSection(UISettingsProvider uiSettings, LocalizationProvider localizationProvider) {  // ← AÑADIR PARÁMETRO
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
            child: Row(
              children: [
                const Icon(Icons.palette, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).appearance,  // ← Ahora usará traducción
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _buildSettingsItem(
                Icons.language,
                AppLocalizations.of(context).language,  // ← Ahora usará traducción
                localizationProvider.currentLanguageName,
                    () => _showLanguageDialog(),
              ),

              
              const Divider(height: 1),  // ← AÑADE ESTE DIVIDER
              _buildSettingsItem(
                Icons.text_fields,
                AppLocalizations.of(context).textSize,  // ← Ahora usará traducción
                uiSettings.textSizeDisplayName,
                    () => _showTextSizeDialog(uiSettings),
              ),
            ],
          ),
        ],
      ),
    );
  }

// 🌐 SECCIÓN DE PERSONALIZACIÓN
  Widget _buildPersonalizationSection() {
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
                Icon(Icons.tune, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Personalización',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [

            ],
          ),
        ],
      ),
    );
  }



  Widget _buildThemeOption(String title, String value, IconData icon, Color color) {
    final isSelected = _selectedTheme == value;

    return GestureDetector(
      onTap: () => _changeTheme(value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }


// 🔧 FUNCIONES DE FUNCIONALIDAD

// Cargar configuraciones de personalización
  Future<void> _loadPersonalizationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedTheme = prefs.getString('theme') ?? 'light';
        _selectedLanguage = prefs.getString('language') ?? 'es';
        _textScale = prefs.getDouble('text_scale') ?? 1.0;
        _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      });
    } catch (e) {
      debugPrint('Error loading personalization settings: $e');
    }
  }

// Verificar disponibilidad biométrica
  Future<void> _checkBiometricAvailability() async {
    try {
      // Simular verificación biométrica (reemplazar con local_auth)
      setState(() {
        _biometricAvailable = true; // Cambiar según disponibilidad real
      });
    } catch (e) {
      setState(() {
        _biometricAvailable = false;
      });
    }
  }

// Cambiar tema
  Future<void> _changeTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', theme);

      setState(() {
        _selectedTheme = theme;
      });

      _showSuccessSnackBar('🎨 Tema cambiado a ${_getThemeLabel(theme)}');

      // Aquí implementarías el cambio real del tema
      // Por ejemplo, con un ThemeProvider

    } catch (e) {
      _showErrorSnackBar('Error al cambiar tema: $e');
    }
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light': return 'Claro';
      case 'dark': return 'Oscuro';
      case 'system': return 'Sistema';
      default: return 'Claro';
    }
  }



// Cambiar idioma
  Future<void> _changeLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);

      setState(() {
        _selectedLanguage = language;
      });

      _showSuccessSnackBar('🌐 Idioma cambiado a ${language == 'es' ? 'Español' : 'English'}');

      // Aquí implementarías el cambio real del idioma
      // Por ejemplo, con intl o easy_localization

    } catch (e) {
      _showErrorSnackBar('Error al cambiar idioma: $e');
    }
  }


// Cambiar tamaño de texto
  Future<void> _changeTextSize(double scale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('text_scale', scale);

      setState(() {
        _textScale = scale;
      });

      _showSuccessSnackBar('📝 Tamaño de texto cambiado');

      // Aquí implementarías el cambio real del tamaño
      // Por ejemplo, con MediaQuery.textScaleFactorOf

    } catch (e) {
      _showErrorSnackBar('Error al cambiar tamaño de texto: $e');
    }
  }

  String _getTextSizeLabel() {
    switch (_textScale) {
      case 0.8: return 'Pequeño';
      case 1.0: return 'Normal';
      case 1.2: return 'Grande';
      case 1.4: return 'Muy Grande';
      default: return 'Normal';
    }
  }

// Alternar biométrica
  Future<void> _toggleBiometric(bool value) async {
    try {
      if (value) {
        // Aquí implementarías la autenticación biométrica real
        // usando local_auth package
        _showSuccessSnackBar('🔐 Autenticación biométrica activada');
      } else {
        _showSuccessSnackBar('🔓 Autenticación biométrica desactivada');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', value);

      setState(() {
        _biometricEnabled = value;
      });

    } catch (e) {
      _showErrorSnackBar('Error al configurar biométrica: $e');
    }
  }

  // 🔒 Mostrar opciones de seguridad
  void _showSecurityOptions() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Configuración de Seguridad'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🔐 Tu cuenta está protegida con:'),
                SizedBox(height: 12),
                Text('• Autenticación por email y contraseña'),
                Text('• Encriptación de datos en tránsito'),
                Text('• Sesiones con tiempo de expiración'),
                Text('• Separación de datos por empresa'),
                SizedBox(height: 16),
                Text('✅ Tu información está segura'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  // 💾 Crear backup
  void _createBackup() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Copia de Seguridad'),
            content: const Text(
              'Tus datos se respaldan automáticamente en la nube de forma segura. '
                  'No necesitas realizar ninguna acción adicional.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  // 👥 Configurar límites de empleados
  void _configureEmployeeLimits() {
    final maxOrderController = TextEditingController();
    final monthlyLimitController = TextEditingController();

    // Cargar valores actuales del provider
    final authProvider = context.read<RestauAuthProvider>();
    final settings = authProvider.companyData?['settings'] ?? {};
    maxOrderController.text = (settings['maxOrderAmount'] ?? 500.0).toString();
    monthlyLimitController.text =
        (settings['monthlyLimitPerEmployee'] ?? 2000.0).toString();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Límites de Empleados'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: maxOrderController,
                    decoration: const InputDecoration(
                      labelText: 'Límite por pedido (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: monthlyLimitController,
                    decoration: const InputDecoration(
                      labelText: 'Límite mensual por empleado (€)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
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
                onPressed: () =>
                    _saveEmployeeLimits(
                      double.tryParse(maxOrderController.text) ?? 500.0,
                      double.tryParse(monthlyLimitController.text) ?? 2000.0,
                    ),
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  // 💾 Guardar límites de empleados
  Future<void> _saveEmployeeLimits(double maxOrder, double monthlyLimit) async {
    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId != null) {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .update({
          'settings.maxOrderAmount': maxOrder,
          'settings.monthlyLimitPerEmployee': monthlyLimit,
          'settings.employeeOrderLimits': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Actualizar datos locales
        await authProvider.refreshUserData();

        if (mounted) {
          Navigator.pop(context);
          _showSuccessSnackBar('✅ Límites de empleados actualizados');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Error al actualizar límites: $e');
      }
    }
  }

  // 📋 Configurar políticas de empresa - VERSIÓN FUNCIONAL
  void _configureCompanyPolicies() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CompanyPoliciesScreen(),
      ),
    );
  }

  // 📊 Mostrar reportes de empleados
  void _showEmployeeReports() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Reportes de Actividad'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de Actividad',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Text('👥 Empleados activos: En desarrollo'),
                  Text('📝 Pedidos este mes: En desarrollo'),
                  Text('💰 Gasto mensual: En desarrollo'),
                  Text('🏆 Empleado más activo: En desarrollo'),
                  SizedBox(height: 16),
                  Text(
                    'Los reportes detallados estarán disponibles en una próxima actualización.',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.secondaryTextColor),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // 🆘 Abrir centro de ayuda
  void _openHelpCenter() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Centro de Ayuda'),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❓ Preguntas Frecuentes:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• ¿Cómo añadir un nuevo proveedor?'),
                  Text('• ¿Cómo importar productos desde Excel?'),
                  Text('• ¿Cómo aprobar pedidos de empleados?'),
                  Text('• ¿Cómo generar PDFs de pedidos?'),
                  SizedBox(height: 16),
                  Text('💡 Consejos:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('• Mantén actualizada la información de proveedores'),
                  Text('• Configura límites apropiados para empleados'),
                  Text('• Revisa regularmente los pedidos pendientes'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // 📞 Contactar soporte
  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Contactar Soporte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('¿Necesitas ayuda? Contáctanos:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                      Icons.email, color: AppTheme.primaryColor),
                  title: const Text('Email'),
                  subtitle: const Text('soporte@restau-pedidos.com'),
                  onTap: () => _launchEmail('soporte@restau-pedidos.com'),
                ),
                ListTile(
                  leading: const Icon(
                      Icons.phone, color: AppTheme.primaryColor),
                  title: const Text('Teléfono'),
                  subtitle: const Text('+34 900 123 456'),
                  onTap: () => _launchPhone('+34900123456'),
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: AppTheme.primaryColor),
                  title: const Text('WhatsApp'),
                  subtitle: const Text('Chat directo'),
                  onTap: () => _launchWhatsApp('+34900123456'),
                ),
              ],
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

  // 🌐 Funciones para abrir enlaces externos
  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Soporte MiProveedor&body=Describe tu consulta aquí...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showErrorSnackBar('No se pudo abrir el cliente de email');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showErrorSnackBar('No se pudo abrir el marcador');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse(
        'https://wa.me/$phone?text=Hola, necesito ayuda con MiProveedor');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showErrorSnackBar('No se pudo abrir WhatsApp');
    }
  }

  // 💬 Enviar comentarios
  void _sendFeedback() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Enviar Comentarios'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Nos encantaría conocer tu experiencia:'),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tus comentarios aquí...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => _submitFeedback(feedbackController.text),
                child: const Text('Enviar'),
              ),
            ],
          ),
    );
  }

  // 📤 Enviar feedback a Firestore
  Future<void> _submitFeedback(String feedback) async {
    if (feedback
        .trim()
        .isEmpty) {
      _showErrorSnackBar('Por favor escribe tu comentario');
      return;
    }

    try {
      final authProvider = context.read<RestauAuthProvider>();

      await FirebaseFirestore.instance.collection('feedback').add({
        'userId': authProvider.user?.uid,
        'userEmail': authProvider.user?.email,
        'companyId': authProvider.companyId,
        'feedback': feedback.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      if (mounted) {
        Navigator.pop(context);
        _showSuccessSnackBar('✅ ¡Gracias por tu comentario!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('❌ Error al enviar comentario: $e');
      }
    }
  }

  // ℹ️ Mostrar información de la app
  void _showAboutDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Acerca de MiProveedor'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                            Icons.restaurant, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MiProveedor',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('Versión ${packageInfo.version}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                      '🍽️ Gestión inteligente de pedidos para restaurantes'),
                  const SizedBox(height: 12),
                  const Text('📱 Desarrollado por MobilePro'),
                  const SizedBox(height: 12),
                  const Text('© 2024 Todos los derechos reservados'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
      );
    }
  }

  // 📄 Mostrar términos y condiciones
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Términos y Condiciones'),
            content: const SingleChildScrollView(
              child: Text(
                'TÉRMINOS Y CONDICIONES DE USO\n\n'
                    '1. ACEPTACIÓN DE LOS TÉRMINOS\n'
                    'Al utilizar MiProveedor, aceptas estos términos.\n\n'
                    '2. DESCRIPCIÓN DEL SERVICIO\n'
                    'MiProveedor es una aplicación para gestión de pedidos a proveedores.\n\n'
                    '3. RESPONSABILIDADES DEL USUARIO\n'
                    '- Proporcionar información veraz\n'
                    '- Mantener segura tu cuenta\n'
                    '- Usar el servicio de manera apropiada\n\n'
                    '4. LIMITACIONES\n'
                    'El servicio se proporciona "tal como está".\n\n'
                    '5. MODIFICACIONES\n'
                    'Nos reservamos el derecho de modificar estos términos.',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // 🔒 Mostrar política de privacidad
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Política de Privacidad'),
            content: const SingleChildScrollView(
              child: Text(
                'POLÍTICA DE PRIVACIDAD\n\n'
                    '1. INFORMACIÓN QUE RECOPILAMOS\n'
                    '- Datos de registro (email, nombre)\n'
                    '- Información de empresa y empleados\n'
                    '- Datos de pedidos y proveedores\n\n'
                    '2. CÓMO USAMOS TU INFORMACIÓN\n'
                    '- Proporcionar el servicio\n'
                    '- Mejorar la experiencia\n'
                    '- Comunicarnos contigo\n\n'
                    '3. PROTECCIÓN DE DATOS\n'
                    '- Encriptación en tránsito y reposo\n'
                    '- Acceso restringido\n'
                    '- Servidores seguros\n\n'
                    '4. TUS DERECHOS\n'
                    '- Acceder a tus datos\n'
                    '- Corregir información\n'
                    '- Eliminar cuenta\n\n'
                    '5. CONTACTO\n'
                    'privacidad@Mi-Proveedor.com',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // ⭐ Calificar app - VERSIÓN FUNCIONAL
  void _rateApp() async {
    try {
      // URLs de las stores (necesitas cambiar por las URLs reales cuando publiques)
      const String appStoreUrl = 'https://apps.apple.com/app/restau-pedidos/id123456789';
      const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.mobilepro.restau_pedidos';

      // Detectar plataforma y abrir store correspondiente
      String storeUrl;
      if (Theme
          .of(context)
          .platform == TargetPlatform.iOS) {
        storeUrl = appStoreUrl;
      } else {
        storeUrl = playStoreUrl;
      }

      final Uri url = Uri.parse(storeUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication, // Abre en app de store
        );
      } else {
        // Fallback: mostrar diálogo explicativo
        _showRatingFallbackDialog();
      }
    } catch (e) {
      _showErrorSnackBar('❌ Error al abrir la tienda: $e');
    }
  }

// Diálogo alternativo si no puede abrir stores
  void _showRatingFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Calificar MiProveedor'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Para calificar la app:'),
                SizedBox(height: 16),
                Text('📱 iOS: Busca "MiProveedor" en App Store'),
                Text('🤖 Android: Busca "MiProveedor" en Play Store'),
                SizedBox(height: 16),
                Text('⭐ ¡Tu calificación nos ayuda mucho!'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  // ❓ Mostrar diálogo de ayuda rápida
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.help, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text('Ayuda Rápida'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 Consejos rápidos:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Edita tu información de empresa tocando el ícono ✏️'),
                Text('• Configura notificaciones según tus preferencias'),
                Text('• Cambia tu contraseña regularmente'),
                Text('• Comparte el código de empresa con empleados'),
                SizedBox(height: 12),
                Text(
                    '¿Necesitas más ayuda? Usa "Contactar Soporte" más abajo.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  // 🚪 Confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context,
      RestauAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Cerrar diálogo primero

                  try {
                    // Logout sin mostrar loading extra
                    await authProvider.logout();

                    // La navegación la debe manejar el AuthProvider automáticamente
                    // No necesitamos hacer nada más aquí

                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al cerrar sesión: $e'),
                          backgroundColor: AppTheme.errorColor,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor),
                child: const Text(
                    'Cerrar Sesión', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // 💾 FUNCIONES DE PERSISTENCIA LOCAL

  // Cargar configuraciones de notificaciones
  void _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('push_notifications') ?? true;
        _emailNotifications = prefs.getBool('email_notifications') ?? true;
        _orderNotifications = prefs.getBool('order_notifications') ?? true;
        _employeeNotifications =
            prefs.getBool('employee_notifications') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
  }

  // Guardar configuraciones de notificaciones
  void _saveNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', _pushNotifications);
      await prefs.setBool('email_notifications', _emailNotifications);
      await prefs.setBool('order_notifications', _orderNotifications);
      await prefs.setBool('employee_notifications', _employeeNotifications);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  // 🌍 Mostrar diálogo de idioma (5 IDIOMAS COMPLETOS)
  void _showLanguageDialog() {
    final localizationProvider = context.read<LocalizationProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.language, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Seleccionar Idioma'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🇪🇸 ESPAÑOL
            RadioListTile<String>(
              title: Text('🇪🇸 Español'),
              subtitle: Text('Español'),
              value: 'es',
              groupValue: localizationProvider.currentLanguageCode,
              onChanged: (value) async {
                Navigator.pop(context);
                await localizationProvider.setLocale(Locale(value!));
                _showSuccessSnackBar('🌍 Idioma cambiado a Español');
              },
              activeColor: AppTheme.primaryColor,
            ),

            // 🇺🇸 INGLÉS
            RadioListTile<String>(
              title: Text('🇺🇸 English'),
              subtitle: Text('English'),
              value: 'en',
              groupValue: localizationProvider.currentLanguageCode,
              onChanged: (value) async {
                Navigator.pop(context);
                await localizationProvider.setLocale(Locale(value!));
                _showSuccessSnackBar('🌍 Language changed to English');
              },
              activeColor: AppTheme.primaryColor,
            ),

            // 🏴󠁥󠁳󠁣󠁴󠁿 CATALÁN
            RadioListTile<String>(
              title: Text('🏴󠁥󠁳󠁣󠁴󠁿 Català'),
              subtitle: Text('Català'),
              value: 'ca',
              groupValue: localizationProvider.currentLanguageCode,
              onChanged: (value) async {
                Navigator.pop(context);
                await localizationProvider.setLocale(Locale(value!));
                _showSuccessSnackBar('🌍 Idioma canviat a Català');
              },
              activeColor: AppTheme.primaryColor,
            ),

            // 🇫🇷 FRANCÉS
            RadioListTile<String>(
              title: Text('🇫🇷 Français'),
              subtitle: Text('Français'),
              value: 'fr',
              groupValue: localizationProvider.currentLanguageCode,
              onChanged: (value) async {
                Navigator.pop(context);
                await localizationProvider.setLocale(Locale(value!));
                _showSuccessSnackBar('🌍 Langue changée en Français');
              },
              activeColor: AppTheme.primaryColor,
            ),

            // 🇮🇹 ITALIANO
            RadioListTile<String>(
              title: Text('🇮🇹 Italiano'),
              subtitle: Text('Italiano'),
              value: 'it',
              groupValue: localizationProvider.currentLanguageCode,
              onChanged: (value) async {
                Navigator.pop(context);
                await localizationProvider.setLocale(Locale(value!));
                _showSuccessSnackBar('🌍 Lingua cambiata in Italiano');
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await localizationProvider.resetToDeviceLanguage();
              _showSuccessSnackBar('🔄 Idioma reseteado a configuración del dispositivo');
            },
            icon: Icon(Icons.refresh),
            label: Text('Auto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }



  // 📝 Mostrar diálogo de tamaño de texto (FUNCIONAL)
  void _showTextSizeDialog(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tamaño de Texto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<double>(
              title: Text(
                'Pequeño',
                style: TextStyle(fontSize: 16 * 0.8),
              ),
              value: 0.8,
              groupValue: uiSettings.textScale,
              onChanged: (value) {
                Navigator.pop(context);
                uiSettings.setTextScale(value!);
                _showSuccessSnackBar('📝 Tamaño cambiado a Pequeño');
              },
              activeColor: AppTheme.primaryColor,
            ),
            RadioListTile<double>(
              title: Text(
                'Normal',
                style: TextStyle(fontSize: 16 * 1.0),
              ),
              value: 1.0,
              groupValue: uiSettings.textScale,
              onChanged: (value) {
                Navigator.pop(context);
                uiSettings.setTextScale(value!);
                _showSuccessSnackBar('📝 Tamaño cambiado a Normal');
              },
              activeColor: AppTheme.primaryColor,
            ),
            RadioListTile<double>(
              title: Text(
                'Grande',
                style: TextStyle(fontSize: 16 * 1.2),
              ),
              value: 1.2,
              groupValue: uiSettings.textScale,
              onChanged: (value) {
                Navigator.pop(context);
                uiSettings.setTextScale(value!);
                _showSuccessSnackBar('📝 Tamaño cambiado a Grande');
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
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

  // 👆 Mostrar opciones biométricas (VERSIÓN COMPLETA Y MEJORADA)
  void _showBiometricOptions(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Autenticación Biométrica'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado actual
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: uiSettings.isBiometricAvailable
                      ? AppTheme.successColor.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: uiSettings.isBiometricAvailable
                        ? AppTheme.successColor
                        : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      uiSettings.isBiometricAvailable
                          ? Icons.check_circle
                          : Icons.warning,
                      color: uiSettings.isBiometricAvailable
                          ? AppTheme.successColor
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estado: ${uiSettings.biometricStatusText}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: uiSettings.isBiometricAvailable
                              ? AppTheme.successColor
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Información según disponibilidad
              if (uiSettings.isBiometricAvailable) ...[
                const Text(
                  '🔐 La autenticación biométrica te permite:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text('• Acceso rápido y seguro'),
                const Text('• No necesitas recordar tu contraseña'),
                const Text('• Mayor seguridad para tu cuenta'),
                const Text('• Experiencia más fluida'),
                const SizedBox(height: 16),

                // Tipos de biometría detectados
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Métodos disponibles:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Aquí podrías mostrar qué tipos específicos están disponibles
                      Text(
                        '${_getBiometricTypesText()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              ] else ...[
                const Text(
                  '⚠️ La autenticación biométrica no está disponible',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Posibles causas:'),
                const SizedBox(height: 8),
                const Text('• No tienes huellas dactilares o rostro configurados'),
                const Text('• El dispositivo no tiene sensor biométrico'),
                const Text('• La función está deshabilitada en ajustes del sistema'),
                const Text('• Necesitas configurar un método de bloqueo de pantalla'),
                const SizedBox(height: 16),

                // Instrucciones para habilitar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '💡 Para habilitar:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '1. Ve a Ajustes del dispositivo\n'
                            '2. Busca "Seguridad" o "Biometría"\n'
                            '3. Configura huella dactilar o reconocimiento facial\n'
                            '4. Regresa a la app e intenta de nuevo',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Nota de seguridad
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nota: Los datos biométricos se almacenan de forma segura en tu dispositivo y nunca se envían a nuestros servidores.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (uiSettings.isBiometricAvailable)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);

                // Mostrar loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  final success = await uiSettings.toggleBiometric();

                  // Cerrar loading
                  if (mounted) Navigator.pop(context);

                  // Mostrar resultado
                  if (success) {
                    final message = uiSettings.isBiometricEnabled
                        ? '🔐 Autenticación biométrica activada correctamente'
                        : '🔓 Autenticación biométrica desactivada';
                    _showSuccessSnackBar(message);
                  } else {
                    _showErrorSnackBar('❌ Error al cambiar configuración biométrica');
                  }
                } catch (e) {
                  // Cerrar loading
                  if (mounted) Navigator.pop(context);
                  _showErrorSnackBar('❌ Error: $e');
                }
              },
              icon: Icon(
                uiSettings.isBiometricEnabled
                    ? Icons.fingerprint_outlined
                    : Icons.fingerprint,
              ),
              label: Text(
                uiSettings.isBiometricEnabled ? 'Desactivar' : 'Activar',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: uiSettings.isBiometricEnabled
                    ? Colors.orange
                    : AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
  // 🔍 Función auxiliar para obtener tipos de biometría
  String _getBiometricTypesText() {
    // Aquí podrías implementar lógica para detectar tipos específicos
    // Por ahora, retornamos un texto genérico
    return 'Huella dactilar, reconocimiento facial o iris (según disponibilidad del dispositivo)';
  }

  // 📱 UTILIDADES PARA SNACKBARS MEJORADAS
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      // Limpiar SnackBars anteriores para evitar acumulación
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 1500),
          // ← Más rápido (1.5s)
          dismissDirection: DismissDirection.horizontal, // ← Swipe para cerrar
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      // Limpiar SnackBars anteriores para evitar acumulación
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 2000),
          // ← Más rápido (2s)
          dismissDirection: DismissDirection.horizontal,
          // ← Swipe para cerrar
          action: SnackBarAction( // ← Botón para cerrar inmediatamente
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
