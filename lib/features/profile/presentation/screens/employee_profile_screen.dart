import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import '../../../../core/providers/ui_settings_provider.dart';

/// 👤 PANTALLA DE PERFIL DE EMPLEADO
/// Configuración personal adaptada para empleados
class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  // 👤 CONTROLADORES PARA EDITAR PERFIL PERSONAL
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();

  // 🔔 CONFIGURACIONES DE NOTIFICACIONES
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _orderNotifications = true;
  bool _soundNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadPersonalSettings();
    _initializeUISettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeUISettings() async {
    final uiSettings = context.read<UISettingsProvider>();
    await uiSettings.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final userData = authProvider.userData;
    final companyData = authProvider.companyData;

    return Consumer<UISettingsProvider>(
      builder: (context, uiSettings, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(uiSettings.textScale),
          ),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // 🎨 Header con perfil del empleado
                  _buildProfileHeader(context, userData),

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

                          // 👤 Información Personal (EDITABLE)
                          _buildPersonalInfoSection(userData),

                          const SizedBox(height: 20),

                          // 🏢 Información de la Empresa (SOLO LECTURA)
                          _buildCompanyInfoSection(companyData),

                          const SizedBox(height: 20),

                          // 🔔 Configuración de Notificaciones
                          _buildNotificationsSection(),

                          const SizedBox(height: 20),

                          // 🎨 Configuración de Apariencia (ACTUALIZADA)
                          _buildAppearanceSection(uiSettings),

                          const SizedBox(height: 20),

                          // 🔐 Seguridad Personal (ACTUALIZADA)
                          _buildSecuritySection(uiSettings),

                          const SizedBox(height: 20),

                          // 📊 Mis Estadísticas
                          _buildMyStatsSection(),

                          const SizedBox(height: 20),

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

  // 👤 HEADER DEL PERFIL CON AVATAR
  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic>? userData) {
    final userName = userData?['name'] ?? 'Usuario';
    final userEmail = userData?['email'] ?? '';
    final userPosition = userData?['position'] ?? 'Empleado';
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                _getInitials(userName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userPosition,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Botón de editar perfil
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => _editPersonalInfo(userData),
            ),
          ),
        ],
      ),
    );
  }

  // 👤 SECCIÓN DE INFORMACIÓN PERSONAL
  Widget _buildPersonalInfoSection(Map<String, dynamic>? userData) {
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
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Mi Información Personal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editPersonalInfo(userData),
                  icon: const Icon(Icons.edit, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow('Nombre', userData?['name'] ?? '', Icons.person),
                const SizedBox(height: 12),
                _buildInfoRow('Email', userData?['email'] ?? '', Icons.email),
                const SizedBox(height: 12),
                _buildInfoRow('Posición', userData?['position'] ?? '', Icons.work),
                const SizedBox(height: 12),
                _buildInfoRow('Teléfono', userData?['phone'] ?? '', Icons.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏢 SECCIÓN DE INFORMACIÓN DE LA EMPRESA (SOLO LECTURA)
  Widget _buildCompanyInfoSection(Map<String, dynamic>? companyData) {
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
                Icon(Icons.business, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Mi Empresa',
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
                _buildInfoRow('Empresa', companyData?['name'] ?? '', Icons.store),
                const SizedBox(height: 12),
                _buildInfoRow('Código', companyData?['code'] ?? '', Icons.qr_code),
                const SizedBox(height: 12),
                _buildInfoRow('Dirección', companyData?['address'] ?? '', Icons.location_on),
                const SizedBox(height: 12),
                _buildInfoRow('Teléfono', companyData?['phone'] ?? '', Icons.phone),
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
                  'Mis Notificaciones',
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
                  'Recibir notificaciones en mi dispositivo',
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
                  'Alertas cuando mis pedidos cambien de estado',
                  Icons.receipt_long,
                  _orderNotifications,
                  (value) => setState(() => _orderNotifications = value),
                ),
                const Divider(),
                _buildNotificationSwitch(
                  'Sonido de Notificaciones',
                  'Reproducir sonido con las notificaciones',
                  Icons.volume_up,
                  _soundNotifications,
                  (value) => setState(() => _soundNotifications = value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 SECCIÓN DE APARIENCIA (FUNCIONAL)
  Widget _buildAppearanceSection(UISettingsProvider uiSettings) {
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
                Icon(Icons.palette, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Apariencia',
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
                Icons.language,
                'Idioma',
                uiSettings.languageDisplayName,
                () => _showLanguageDialog(uiSettings),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.dark_mode,
                'Tema',
                uiSettings.themeDisplayName,
                () => _showThemeDialog(uiSettings),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.text_fields,
                'Tamaño de Texto',
                uiSettings.textSizeDisplayName,
                () => _showTextSizeDialog(uiSettings),
              ),
            ],
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
            'Actualizar mi contraseña de acceso',
            () => _changePassword(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.security,
            'Configuración de Seguridad',
            'Ver configuración de seguridad',
            () => _showSecurityOptions(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.fingerprint,
            'Autenticación Biométrica',
            uiSettings.biometricStatusText,
            () => _showBiometricOptions(uiSettings),
          ),
        ],
      ),
    );
  }

  // 📊 SECCIÓN DE MIS ESTADÍSTICAS
  Widget _buildMyStatsSection() {
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
                Icon(Icons.analytics, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Mis Estadísticas',
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
                _buildStatRow('Pedidos Creados', '12', Icons.receipt_long),
                const SizedBox(height: 12),
                _buildStatRow('Pedidos Aprobados', '10', Icons.check_circle),
                const SizedBox(height: 12),
                _buildStatRow('Valor Total', '€1,250.00', Icons.euro),
                const SizedBox(height: 12),
                _buildStatRow('Promedio por Pedido', '€104.17', Icons.trending_up),
              ],
            ),
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
            'Guías y preguntas frecuentes',
            () => _openHelpCenter(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.support_agent,
            'Contactar Soporte',
            'Obtener ayuda del equipo de soporte',
            () => _contactSupport(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.feedback,
            'Enviar Comentarios',
            'Comparte tu experiencia con nosotros',
            () => _sendFeedback(),
          ),
          const Divider(height: 1),
          _buildSettingsItem(
            Icons.bug_report,
            'Reportar Problema',
            'Reportar un error o problema',
            () => _reportBug(),
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
                  color: value.isNotEmpty ? AppTheme.textColor : AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
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
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
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
            _savePersonalSettings();
          },
          activeColor: AppTheme.primaryColor,
        ),
      ],
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

  // 📱 FUNCIONES DE FUNCIONALIDAD NUEVAS Y ACTUALIZADAS

  // 🌍 Mostrar diálogo de idioma (FUNCIONAL)
  void _showLanguageDialog(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Seleccionar Idioma'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: uiSettings.availableLanguages.map((language) {
            return RadioListTile<String>(
              title: Text(language['name']!),
              subtitle: Text(language['nativeName']!),
              value: language['code']!,
              groupValue: uiSettings.selectedLanguage,
              onChanged: (value) async {
                if (value != null) {
                  await uiSettings.setLanguage(value);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Idioma cambiado a ${language['name']}'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  // 🌓 Mostrar diálogo de tema (FUNCIONAL)
  void _showThemeDialog(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dark_mode, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Seleccionar Tema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('🌞 Tema Claro'),
              subtitle: const Text('Apariencia clara y brillante'),
              value: ThemeMode.light,
              groupValue: uiSettings.themeMode,
              onChanged: (value) async {
                if (value != null) {
                  await uiSettings.setThemeMode(value);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Tema claro activado'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('🌚 Tema Oscuro'),
              subtitle: const Text('Apariencia oscura y elegante'),
              value: ThemeMode.dark,
              groupValue: uiSettings.themeMode,
              onChanged: (value) async {
                if (value != null) {
                  await uiSettings.setThemeMode(value);
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Tema oscuro activado'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
            ),
            SwitchListTile(
              title: const Text('🔄 Automático'),
              subtitle: const Text('Seguir configuración del sistema'),
              value: uiSettings.useSystemTheme,
              onChanged: (value) async {
                await uiSettings.setSystemTheme(value);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value 
                      ? '✅ Tema automático activado'
                      : '✅ Tema automático desactivado'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
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

  // 📝 Mostrar diálogo de tamaño de texto (FUNCIONAL)
  void _showTextSizeDialog(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.text_fields, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Tamaño de Texto'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ajusta el tamaño del texto a tu preferencia',
                style: TextStyle(fontSize: 14 * uiSettings.textScale),
              ),
              const SizedBox(height: 20),
              
              // Preview del texto
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Ejemplo de texto',
                      style: TextStyle(
                        fontSize: 16 * uiSettings.textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Este es el tamaño que verás en la aplicación',
                      style: TextStyle(fontSize: 14 * uiSettings.textScale),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Slider para ajustar tamaño
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: uiSettings.textScale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      label: '${(uiSettings.textScale * 100).round()}%',
                      onChanged: (value) {
                        setDialogState(() {
                          uiSettings.setTextScale(value);
                        });
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 18)),
                ],
              ),
              
              // Opciones rápidas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => setDialogState(() {
                      uiSettings.setTextScale(0.9);
                    }),
                    child: const Text('Pequeño'),
                  ),
                  TextButton(
                    onPressed: () => setDialogState(() {
                      uiSettings.setTextScale(1.0);
                    }),
                    child: const Text('Normal'),
                  ),
                  TextButton(
                    onPressed: () => setDialogState(() {
                      uiSettings.setTextScale(1.2);
                    }),
                    child: const Text('Grande'),
                  ),
                ],
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
      ),
    );
  }

  void _showBiometricOptions(UISettingsProvider uiSettings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fingerprint, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            // Usamos Flexible para que el título no cause desbordamiento si es muy largo
            const Flexible(child: Text('Autenticación Biométrica')),
          ],
        ),
        // Se envuelve el contenido en un SingleChildScrollView para evitar desbordamiento vertical y horizontal
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (uiSettings.isBiometricAvailable) ...[
                  Text(
                    '🔒 Estado: ${uiSettings.biometricStatusText}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text('¿Qué es la autenticación biométrica?'),
                  const SizedBox(height: 8),
                  const Text(
                    'Te permite acceder a la aplicación usando tu huella dactilar, '
                        'reconocimiento facial u otros métodos biométricos disponibles en tu dispositivo.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text(uiSettings.isBiometricEnabled
                        ? 'Deshabilitar Biometría'
                        : 'Habilitar Biometría'),
                    subtitle: Text(uiSettings.isBiometricEnabled
                        ? 'Usar solo email y contraseña'
                        : 'Usar datos biométricos para acceder'),
                    value: uiSettings.isBiometricEnabled,
                    onChanged: (value) async {
                      final success = await uiSettings.toggleBiometric();
                      if (mounted) {
                        if (success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value
                                  ? '✅ Autenticación biométrica habilitada'
                                  : '✅ Autenticación biométrica deshabilitada'),
                              backgroundColor: AppTheme.successColor,
                            ),
                          );
                        } else if (uiSettings.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ${uiSettings.error}'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                          uiSettings.clearError();
                        }
                      }
                    },
                  ),
                ] else ...[
                  const Text('❌ Autenticación biométrica no disponible'),
                  const SizedBox(height: 12),
                  const Text(
                    'Tu dispositivo no soporta autenticación biométrica o '
                        'no tienes datos biométricos configurados.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Para usar esta función, configura la huella dactilar o '
                        'reconocimiento facial en la configuración de tu dispositivo.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          if (uiSettings.isBiometricAvailable && uiSettings.isBiometricEnabled)
            ElevatedButton(
              onPressed: () async {
                final success = await uiSettings.authenticateWithBiometric(
                  reason: 'Probar autenticación biométrica',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? '✅ Autenticación exitosa'
                          : '❌ Autenticación fallida'),
                      backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  );
                }
              },
              child: const Text('Probar'),
            ),
        ],
      ),
    );
  }


  // 🔧 Editar información personal
  void _editPersonalInfo(Map<String, dynamic>? userData) {
    _nameController.text = userData?['name'] ?? '';
    _emailController.text = userData?['email'] ?? '';
    _positionController.text = userData?['position'] ?? '';
    _phoneController.text = userData?['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Mi Información'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: false, // Email no editable
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Posición/Cargo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
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
            onPressed: () => _savePersonalInfo(),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // 💾 Guardar información personal
  Future<void> _savePersonalInfo() async {
    try {
      final authProvider = context.read<RestauAuthProvider>();
      final userId = authProvider.currentUser?.uid;
      final companyId = authProvider.companyId;

      if (userId != null && companyId != null) {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('employees')
            .doc(userId)
            .update({
          'name': _nameController.text.trim(),
          'position': _positionController.text.trim(),
          'phone': _phoneController.text.trim(),
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

  // 🔐 Cambiar contraseña
  void _changePassword() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Mi Contraseña'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña actual',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
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
            onPressed: () => _updatePassword(
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
  Future<void> _updatePassword(String current, String newPassword, String confirm) async {
    if (newPassword != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Las contraseñas no coinciden'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Re-autenticar con contraseña actual
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: current,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Contraseña actualizada correctamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cambiar contraseña: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // 🔒 Mostrar opciones de seguridad
  void _showSecurityOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mi Seguridad'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔐 Tu cuenta está protegida con:'),
            SizedBox(height: 12),
            Text('• Autenticación por email y contraseña'),
            Text('• Encriptación de datos en tránsito'),
            Text('• Sesiones con tiempo de expiración'),
            Text('• Acceso restringido por empresa'),
            SizedBox(height: 16),
            Text('✅ Tu información personal está segura'),
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

  // 🆘 Funciones de ayuda y soporte
  void _openHelpCenter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centro de Ayuda'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❓ Preguntas Frecuentes:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• ¿Cómo crear un pedido?'),
              Text('• ¿Cómo ver el estado de mis pedidos?'),
              Text('• ¿Cómo buscar productos?'),
              Text('• ¿Cómo contactar a mi supervisor?'),
              SizedBox(height: 16),
              Text('💡 Consejos para empleados:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('• Revisa siempre los detalles antes de enviar'),
              Text('• Mantén actualizada tu información personal'),
              Text('• Configura tus notificaciones apropiadamente'),
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

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contactar Soporte'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Necesitas ayuda? Contáctanos:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Expanded(child: Text('soporte@restau-pedidos.com')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text('+34 900 123 456'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text('Lun-Vie 9:00-18:00'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📧 Función de email se implementará próximamente')),
              );
            },
            child: const Text('Enviar Email'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback() {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar Comentarios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cómo ha sido tu experiencia usando MiProveedor?'),
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ ¡Gracias por tus comentarios!')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _reportBug() {
    final bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar Problema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe el problema que has encontrado:'),
            const SizedBox(height: 16),
            TextField(
              controller: bugController,
              decoration: const InputDecoration(
                hintText: 'Describe el problema detalladamente...',
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🐛 Reporte enviado. ¡Gracias por ayudarnos a mejorar!')),
              );
            },
            child: const Text('Enviar Reporte'),
          ),
        ],
      ),
    );
  }

  // ℹ️ Funciones de información
  void _showAboutDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MiProveedor',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text('Versión ${packageInfo.version}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('🍽️ Gestión inteligente de pedidos para restaurantes'),
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

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidad'),
        content: const SingleChildScrollView(
          child: Text(
            'POLÍTICA DE PRIVACIDAD\n\n'
            '1. INFORMACIÓN QUE RECOPILAMOS\n'
            '- Datos de registro (email, nombre)\n'
            '- Información de pedidos\n'
            '- Datos de uso de la aplicación\n\n'
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
            'privacidad@restau-pedidos.com',
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

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calificar MiProveedor'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Te gusta usar MiProveedor?'),
            SizedBox(height: 16),
            Text('⭐⭐⭐⭐⭐'),
            SizedBox(height: 16),
            Text('Tu opinión nos ayuda a mejorar'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Después'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('⭐ ¡Gracias por tu calificación!')),
              );
            },
            child: const Text('Calificar'),
          ),
        ],
      ),
    );
  }

  // 🚪 Confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context, RestauAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // ✅ SOLUCIÓN: NO mostrar loading dialog problemático
              // El authStateChanges() manejará la navegación automáticamente
              
              try {
                await authProvider.logout();
                // ✅ authStateChanges() detecta signOut() y navega al login
                // NO hay loading dialog que se quede colgado 🚀
              } catch (e) {
                // ❌ Solo si hay error, mostrar mensaje
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
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔧 FUNCIONES UTILITARIAS

  // Obtener iniciales del nombre
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // 💾 FUNCIONES DE PERSISTENCIA LOCAL

  // Cargar configuraciones personales
  void _loadPersonalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _pushNotifications = prefs.getBool('employee_push_notifications') ?? true;
        _emailNotifications = prefs.getBool('employee_email_notifications') ?? true;
        _orderNotifications = prefs.getBool('employee_order_notifications') ?? true;
        _soundNotifications = prefs.getBool('employee_sound_notifications') ?? true;
      });
    } catch (e) {
      debugPrint('Error loading personal settings: $e');
    }
  }

  // Guardar configuraciones personales
  void _savePersonalSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('employee_push_notifications', _pushNotifications);
      await prefs.setBool('employee_email_notifications', _emailNotifications);
      await prefs.setBool('employee_order_notifications', _orderNotifications);
      await prefs.setBool('employee_sound_notifications', _soundNotifications);
    } catch (e) {
      debugPrint('Error saving personal settings: $e');
    }
  }
}
