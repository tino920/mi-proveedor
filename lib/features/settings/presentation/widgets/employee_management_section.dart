import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';

class EmployeeManagementSection extends StatelessWidget {
  const EmployeeManagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    
    // Solo mostrar si es admin
    if (authProvider.userRole != 'admin') {
      return const SizedBox.shrink();
    }

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
                Expanded(
                  child: Text(
                    'Gestión de Empleados',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.security, color: Colors.white, size: 20),
              ],
            ),
          ),
          Column(
            children: [
              _buildSettingsItem(
                Icons.group_add,
                'Límites de Empleados',
                'Configurar límites de pedidos por empleado',
                () => _configureEmployeeLimits(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.rule,
                'Políticas de Empresa',
                'Definir reglas y políticas internas',
                () => _configureCompanyPolicies(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.analytics,
                'Reportes de Actividad',
                'Ver estadísticas de empleados',
                () => _showEmployeeReports(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.schedule,
                'Horarios de Trabajo',
                'Configurar horarios permitidos para pedidos',
                () => _configureWorkingHours(context),
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

  void _configureEmployeeLimits(BuildContext context) {
    final maxOrderController = TextEditingController(text: '500');
    final monthlyLimitController = TextEditingController(text: '2000');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.group_add, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Límites de Empleados'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: maxOrderController,
              decoration: InputDecoration(
                labelText: 'Límite por pedido (€)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.euro),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: monthlyLimitController,
              decoration: InputDecoration(
                labelText: 'Límite mensual por empleado (€)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.calendar_month),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            const Text(
              'Los empleados no podrán crear pedidos que superen estos límites.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
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
                  content: Text('✅ Límites actualizados correctamente'),
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

  void _configureCompanyPolicies(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.rule, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Políticas de Empresa'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('📋 Configuraciones disponibles:', 
                style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              
              _PolicyItem('Aprobación obligatoria', 'Todos los pedidos requieren aprobación', true),
              _PolicyItem('Pedidos fuera de horario', 'Permitir pedidos los fines de semana', false),
              _PolicyItem('Límite de proveedores', 'Restringir empleados a proveedores específicos', false),
              _PolicyItem('Notas obligatorias', 'Requerir notas en pedidos > €200', true),
              
              SizedBox(height: 16),
              Text('Esta funcionalidad se expandirá en próximas versiones.',
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

  void _showEmployeeReports(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Reportes de Actividad'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Estadísticas disponibles:'),
            SizedBox(height: 12),
            _ReportItem('Pedidos por empleado', 'Última semana: 23 pedidos'),
            _ReportItem('Gastos por empleado', 'Promedio mensual: €847'),
            _ReportItem('Proveedores más usados', 'Top 3: Carnes Del Mar, Verduras SA...'),
            _ReportItem('Horarios de actividad', 'Pico: 10:00-12:00'),
            SizedBox(height: 16),
            Text('💡 Reportes detallados estarán disponibles en una próxima actualización.',
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
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _configureWorkingHours(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.schedule, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Horarios de Trabajo'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Configurar cuando los empleados pueden crear pedidos:'),
            const SizedBox(height: 16),
            
            // Horario de trabajo
            SwitchListTile(
              secondary: const Icon(Icons.work, color: AppTheme.primaryColor),
              title: const Text('Restringir a horario laboral'),
              subtitle: const Text('Solo permitir pedidos en horas de trabajo'),
              value: false,
              onChanged: (value) {},
              activeColor: AppTheme.primaryColor,
            ),
            
            const SizedBox(height: 8),
            
            // Configuración de horas
            const Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Inicio',
                      hintText: '09:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Fin',
                      hintText: '18:00',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
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
}

// Widgets auxiliares
class _PolicyItem extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  
  const _PolicyItem(this.title, this.description, this.enabled);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.radio_button_unchecked,
            color: enabled ? AppTheme.successColor : AppTheme.secondaryTextColor,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String value;
  
  const _ReportItem(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
