import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../providers/settings_provider.dart';

class NotificationsSection extends StatelessWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
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
              // Header de la sección
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
                    const Icon(Icons.notifications, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Configuración de Notificaciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        settingsProvider.notificationSummary,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido de la sección
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildNotificationSwitch(
                      'Notificaciones Push',
                      'Recibir notificaciones en el dispositivo',
                      Icons.notifications_active,
                      settingsProvider.pushNotifications,
                      settingsProvider.updatePushNotifications,
                    ),
                    const Divider(height: 24),
                    _buildNotificationSwitch(
                      'Notificaciones por Email',
                      'Recibir notificaciones por correo electrónico',
                      Icons.email,
                      settingsProvider.emailNotifications,
                      settingsProvider.updateEmailNotifications,
                    ),
                    const Divider(height: 24),
                    _buildNotificationSwitch(
                      'Notificaciones de Pedidos',
                      'Alertas sobre nuevos pedidos y cambios de estado',
                      Icons.receipt_long,
                      settingsProvider.orderNotifications,
                      settingsProvider.updateOrderNotifications,
                    ),
                    const Divider(height: 24),
                    _buildNotificationSwitch(
                      'Notificaciones de Empleados',
                      'Alertas sobre actividad de empleados',
                      Icons.people,
                      settingsProvider.employeeNotifications,
                      settingsProvider.updateEmployeeNotifications,
                    ),
                    
                    // Configuración avanzada de notificaciones
                    const SizedBox(height: 16),
                    _buildAdvancedNotificationSettings(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔔 WIDGET PARA SWITCH DE NOTIFICACIÓN
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
            gradient: value 
                ? AppGradients.primaryGradient 
                : LinearGradient(
                    colors: [
                      AppTheme.secondaryTextColor.withOpacity(0.3),
                      AppTheme.secondaryTextColor.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: value ? Colors.white : AppTheme.secondaryTextColor, 
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value ? AppTheme.textColor : AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
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
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          inactiveThumbColor: AppTheme.secondaryTextColor,
          inactiveTrackColor: AppTheme.secondaryTextColor.withOpacity(0.2),
        ),
      ],
    );
  }

  // ⚙️ CONFIGURACIÓN AVANZADA DE NOTIFICACIONES
  Widget _buildAdvancedNotificationSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Configuración Avanzada',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Horarios de notificación
          _buildAdvancedOption(
            'Horarios de Notificación',
            'Configurar cuando recibir notificaciones',
            Icons.schedule,
            () => _showNotificationScheduleDialog(context),
          ),
          const SizedBox(height: 8),
          
          // Tipos de notificación por importancia
          _buildAdvancedOption(
            'Prioridad de Notificaciones',
            'Configurar tipos por importancia',
            Icons.priority_high,
            () => _showNotificationPriorityDialog(context),
          ),
          const SizedBox(height: 8),
          
          // Sonidos de notificación
          _buildAdvancedOption(
            'Sonidos y Vibración',
            'Personalizar alertas sonoras',
            Icons.volume_up,
            () => _showSoundSettingsDialog(context),
          ),
        ],
      ),
    );
  }

  // 📱 WIDGET PARA OPCIÓN AVANZADA
  Widget _buildAdvancedOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppTheme.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  // 📅 DIÁLOGO DE HORARIOS DE NOTIFICACIÓN
  void _showNotificationScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Horarios de Notificación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configurar cuando recibir notificaciones:'),
            const SizedBox(height: 16),
            
            // Horario de trabajo
            ListTile(
              leading: const Icon(Icons.work, color: AppTheme.primaryColor),
              title: const Text('Solo en horario laboral'),
              subtitle: const Text('Lun-Vie 9:00-18:00'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppTheme.primaryColor,
              ),
            ),
            
            // No molestar
            ListTile(
              leading: const Icon(Icons.do_not_disturb, color: AppTheme.primaryColor),
              title: const Text('Modo No Molestar'),
              subtitle: const Text('22:00-08:00'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
                activeColor: AppTheme.primaryColor,
              ),
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
                const SnackBar(
                  content: Text('✅ Horarios configurados'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // 🔔 DIÁLOGO DE PRIORIDAD DE NOTIFICACIONES
  void _showNotificationPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.priority_high, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Prioridad de Notificaciones'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Configurar importancia por tipo:'),
            SizedBox(height: 16),
            
            ListTile(
              leading: Icon(Icons.error, color: Colors.red),
              title: Text('Urgente'),
              subtitle: Text('Pedidos rechazados, errores críticos'),
            ),
            
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Importante'),
              subtitle: Text('Nuevos pedidos, límites superados'),
            ),
            
            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Informativo'),
              subtitle: Text('Actualizaciones, recordatorios'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // 🔊 DIÁLOGO DE CONFIGURACIÓN DE SONIDOS
  void _showSoundSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.volume_up, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Sonidos y Vibración'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Personalizar alertas:'),
            const SizedBox(height: 16),
            
            // Sonido para nuevos pedidos
            ListTile(
              leading: const Icon(Icons.receipt_long, color: AppTheme.primaryColor),
              title: const Text('Nuevos Pedidos'),
              subtitle: const Text('Sonido: Campana suave'),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () {
                  // Reproducir sonido de preview
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🔊 Reproduciendo preview...')),
                  );
                },
              ),
            ),
            
            // Vibración
            SwitchListTile(
              secondary: const Icon(Icons.vibration, color: AppTheme.primaryColor),
              title: const Text('Vibración'),
              subtitle: const Text('Vibrar en notificaciones importantes'),
              value: true,
              onChanged: (value) {},
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
}
