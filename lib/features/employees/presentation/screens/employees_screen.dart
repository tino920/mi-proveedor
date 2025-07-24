import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📋 FIX: Para copiar al portapapeles
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // 📤 FIX: Para compartir
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart' hide GradientContainer;
import '../../../../shared/models/employee_model.dart';
import '../../../employees/providers/employees_provider.dart';
import '../widgets/employees_diagnostic_widget_advanced.dart';
import 'package:intl/intl.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  @override
  void initState() {
    super.initState();
    // 🚀 AUTO-INICIALIZAR: Stream en tiempo real
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesProvider>().autoStartStreamIfReady();
    });
  }

  // 📊 NUEVO: Calcular empleados nuevos desde la lista
  int _getNewEmployeesCount(List<EmployeeModel> employees) {
    final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
    return employees.where((e) => e.joinDate.isAfter(oneMonthAgo)).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF129793)], // ← Estos colores
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header con gradiente
            Container(
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
                      Icons.people,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Empleados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      onPressed: () {
                        _showAddEmployeeDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // 🚀 CONTENIDO CON STREAMBUILDER PARA TIEMPO REAL
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
                child: StreamBuilder<List<EmployeeModel>>(
                  stream: context.read<EmployeesProvider>().employeesStream,
                  builder: (context, snapshot) {
                    // 📡 Estados del Stream
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('🔄 Sincronizando empleados...'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error de conexión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<EmployeesProvider>().autoStartStreamIfReady();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reconectar'),
                            ),
                          ],
                        ),
                      );
                    }

                    final employees = snapshot.data ?? [];
                    
                    return Column(
                      children: [
                        const SizedBox(height: 20),

                        // 📊 Resumen con datos en tiempo real
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GradientContainer(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Total',
                                  '${employees.length}',
                                  Icons.people
                                ),
                                _buildStatItem(
                                  'Activos',
                                  '${employees.where((e) => e.isActive).length}',
                                  Icons.person
                                ),
                                _buildStatItem(
                                  'Nuevos',
                                  '${_getNewEmployeesCount(employees)}',
                                  Icons.person_add
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 📦 Lista sincronizada en tiempo real
                        Expanded(
                          child: employees.isEmpty
                            ? _buildEmptyState()
                            : _buildEmployeesList(employees),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 Método para actualizar empleado
  Future<void> _updateEmployee(
    String employeeId,
    String name,
    String email,
    String position,
    String role,
    bool isActive,
  ) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Actualizando empleado...'),
            ],
          ),
        ),
      );

      // Actualizar en el provider
      await context.read<EmployeesProvider>().updateEmployee(
        employeeId,
        name,
        email,
        position,
        role,
        isActive,
      );

      // Cerrar loading
      Navigator.of(context).pop();

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Empleado "$name" actualizado'),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.of(context).pop();
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Text('Error al actualizar: $e'),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay empleados registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invita a tus empleados para que puedan usar la app',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEmployeeDialog(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Invitar Empleado'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList(List<EmployeeModel> employees) {
    return RefreshIndicator(
      onRefresh: () async {
        // 🔄 El StreamBuilder se actualiza automáticamente
        context.read<EmployeesProvider>().autoStartStreamIfReady();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _buildEmployeeCard(employee);
        },
      ),
    );
  }

  Widget _buildEmployeeCard(EmployeeModel employee) {
    final dateFormat = DateFormat('dd MMM yyyy', 'es_ES');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  employee.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado en iniciales
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del empleado
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          employee.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                            decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: employee.isActive
                              ? AppTheme.successColor.withOpacity(0.1)
                              : AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          employee.isActive ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            color: employee.isActive
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    employee.displayRole,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee.email,
                    style: const TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 14,
                      decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // --- SOLUCIÓN CON WRAP ---
                  // Reemplazamos el Row por un Wrap para evitar el overflow
                  Wrap(
                    spacing: 16.0,      // Espacio horizontal entre los elementos
                    runSpacing: 4.0,   // Espacio vertical si se va a una nueva línea
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Desde ${dateFormat.format(employee.joinDate)}',
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                              decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${employee.ordersCount} pedidos',
                            style: const TextStyle(
                              color: AppTheme.secondaryTextColor,
                              fontSize: 12,
                              decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menú de opciones
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppTheme.secondaryTextColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditEmployeeDialog(employee);
                    break;
                  case 'permissions':
                    _showPermissionsDialog(employee);
                    break;
                  case 'toggle_status':
                    _toggleEmployeeStatus(employee);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'permissions',
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 20),
                      SizedBox(width: 12),
                      Text('Permisos'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        employee.isActive ? Icons.block : Icons.check_circle,
                        size: 20,
                        color: employee.isActive ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        employee.isActive ? 'Desactivar' : 'Activar',
                        style: TextStyle(
                          color: employee.isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final employeesProvider = context.read<EmployeesProvider>();
    final companyCode = employeesProvider.getCompanyCode() ?? 'No disponible';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person_add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Invitar Empleado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Para añadir un nuevo empleado, comparte este código de empresa:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Código de empresa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Código de Empresa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    companyCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'El empleado debe descargar la app y registrarse usando este código.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          GradientButton(
            text: 'Compartir Código',
            icon: Icons.share,
            onPressed: () async {
              await _shareCompanyCode(context, companyCode);
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showEditEmployeeDialog(EmployeeModel employee) {
    final TextEditingController nameController = TextEditingController(text: employee.name);
    final TextEditingController emailController = TextEditingController(text: employee.email);
    final TextEditingController positionController = TextEditingController(text: employee.position ?? '');
    bool isActive = employee.isActive;
    String selectedRole = employee.role;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Editar Empleado',
                  style: const TextStyle(
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... todos los campos del formulario aquí dentro ...
                // Nombre
                const Text(
                  'Nombre Completo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Juan Pérez',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                const Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Ej: juan@restaurant.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Posición
                const Text(
                  'Posición/Cargo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: positionController,
                  decoration: InputDecoration(
                    hintText: 'Ej: Cocinero, Camarero, Chef',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 16),

                // Rol
                const Text(
                  'Rol en el Sistema',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.security),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'employee',
                      child: Text('Empleado'),
                    ),
                    DropdownMenuItem(
                      value: 'manager',
                      child: Text('Gerente'),
                    ),
                    DropdownMenuItem(
                      value: 'admin',
                      child: Text('Administrador'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Estado Activo/Inactivo
                Row(
                  children: [
                    const Icon(Icons.toggle_on, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Estado del empleado',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                        ),
                      ),
                    ),
                    Switch(
                      value: isActive,
                      activeColor: AppTheme.successColor,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isActive ? 'Empleado activo - Puede usar la app' : 'Empleado inactivo - No puede usar la app',
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? AppTheme.successColor : AppTheme.errorColor,
                    decoration: TextDecoration.none, // 🔧 FIX: Sin subrayado
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            GradientButton(
              text: 'Guardar Cambios',
              icon: Icons.save,
              onPressed: () async {
                // Validaciones básicas
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es obligatorio')),
                  );
                  return;
                }

                if (emailController.text.trim().isEmpty || !emailController.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email inválido')),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                // Actualizar empleado
                await _updateEmployee(
                  employee.uid,
                  nameController.text.trim(),
                  emailController.text.trim(),
                  positionController.text.trim(),
                  selectedRole,
                  isActive,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPermissionsDialog(EmployeeModel employee) {
    // TODO: Implementar diálogo de permisos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de permisos pendiente de implementar'),
      ),
    );
  }

  void _toggleEmployeeStatus(EmployeeModel employee) {
    final employeesProvider = context.read<EmployeesProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(employee.isActive ? 'Desactivar Empleado' : 'Activar Empleado'),
        content: Text(
          employee.isActive
            ? '¿Estás seguro de que deseas desactivar a ${employee.name}? No podrá acceder a la app.'
            : '¿Estás seguro de que deseas activar a ${employee.name}? Podrá acceder a la app nuevamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await employeesProvider.toggleEmployeeStatus(employee.uid);

              if (employeesProvider.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      employee.isActive
                        ? 'Empleado desactivado correctamente'
                        : 'Empleado activado correctamente'
                    ),
                  ),
                );
              }
            },
            child: Text(employee.isActive ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  // 📤 FUNCIÓN PARA COMPARTIR CÓDIGO DE EMPRESA
  Future<void> _shareCompanyCode(BuildContext context, String companyCode) async {
    try {
      // 📄 Crear mensaje completo para compartir
      final shareMessage = '''
🎉 ¡Te invito a unirte a nuestro equipo en MiProveedor!

🏢 Para registrarte como empleado:
1️⃣ Descarga la app "MiProveedor"
2️⃣ Selecciona "Registrarse como Empleado"
3️⃣ Usa este código de empresa:

🔑 Código: $companyCode

📱 Con MiProveedor podrás:
• Crear pedidos rápidamente
• Ver el estado de tus pedidos
• Acceder al catálogo completo
• Trabajar de forma más eficiente

¡Nos vemos en la app! 🚀''';

      // 📤 Mostrar opciones de compartir
      final result = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Compartir Código de Empresa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                companyCode,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              
              // Opciones de compartir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    Icons.share,
                    'Compartir',
                    'share',
                    AppTheme.primaryColor,
                  ),
                  _buildShareOption(
                    Icons.content_copy,
                    'Copiar',
                    'copy',
                    AppTheme.successColor,
                  ),
                  _buildShareOption(
                    Icons.message,
                    'WhatsApp',
                    'whatsapp',
                    const Color(0xFF25D366),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      );

      // 🎯 Ejecutar acción seleccionada
      if (result != null && context.mounted) {
        switch (result) {
          case 'share':
            await Share.share(
              shareMessage,
              subject: 'Invitación a MiProveedor - Código: $companyCode',
            );
            _showSuccessMessage(context, '📤 ¡Código compartido exitosamente!');
            break;
            
          case 'copy':
            await Clipboard.setData(ClipboardData(text: companyCode));
            _showSuccessMessage(context, '📋 Código copiado al portapapeles');
            break;
            
          case 'whatsapp':
            // URL encode del mensaje para WhatsApp
            final whatsappMessage = Uri.encodeComponent(shareMessage);
            final whatsappUrl = 'https://wa.me/?text=$whatsappMessage';
            
            try {
              await Share.share(
                shareMessage,
                subject: 'Código MiProveedor'
                    ': $companyCode',
              );
              _showSuccessMessage(context, '📱 Abriendo WhatsApp...');
            } catch (e) {
              // Fallback a share normal si WhatsApp no está disponible
              await Share.share(shareMessage);
              _showSuccessMessage(context, '📤 Código compartido');
            }
            break;
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al compartir: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // 🎨 Widget para opciones de compartir
  Widget _buildShareOption(IconData icon, String label, String action, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, action),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Mostrar mensaje de éxito
  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
