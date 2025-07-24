import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../shared/widgets/gradient_widgets.dart' hide GradientContainer;
import '../../suppliers/presentation/screens/suppliers_screen.dart';
import 'widgets/quick_stats_card.dart';
import '../../employees/presentation/screens/employees_screen.dart';
import '../../orders/presentation/screens/admin_orders_screen.dart';
import '../../orders/providers/orders_provider.dart';
import '../../settings/presentation/screens/settings_screen.dart';
import '../../../shared/models/order_model.dart';
import 'package:mi_proveedor/generated/l10n/app_localizations.dart' as l10n;

/// 🏠 DASHBOARD PRINCIPAL DEL ADMINISTRADOR
/// Pantalla principal que contiene la navegación inferior y gestiona las diferentes secciones
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const SuppliersScreen(),
    const AdminOrdersScreen(),
    const EmployeesScreen(),
    const SettingsScreen(), // 🔧 Importada desde settings module
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.secondaryTextColor,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              label: l10n.AppLocalizations.of(context).dashboard, // 🌍 Localizado
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.business),
              label: l10n.AppLocalizations.of(context).suppliers, // 🌍 Localizado
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.shopping_cart),
              label: l10n.AppLocalizations.of(context).orders, // 🌍 Localizado
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.people),
              label: l10n.AppLocalizations.of(context).employees, // 🌍 Localizado
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: l10n.AppLocalizations.of(context).settings, // 🌍 Localizado
            ),
          ],
        ),
      ),
    );
  }
}

/// 🏠 PANTALLA DE INICIO DEL ADMIN CON DATOS DINÁMICOS
/// Muestra resumen ejecutivo, pedidos pendientes y acciones rápidas
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final userName = authProvider.userData?['name'] ?? 'Admin';
    final companyName = authProvider.companyData?['name'] ?? 'Mi Restaurante';
    final companyId = authProvider.companyId;

    if (companyId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => OrdersProvider(),
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
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hola, $userName 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                companyName,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 🔔 NOTIFICACIONES DINÁMICAS
                        _buildNotificationIcon(companyId),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 📊 RESUMEN DINÁMICO
                    _buildDynamicSummary(companyId),
                  ],
                ),
              ),

              // 📱 Contenido principal con fondo blanco
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          '⏳ Pedidos Pendientes',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 📝 PEDIDOS PENDIENTES DINÁMICOS
                        _buildDynamicPendingOrders(companyId),

                        const SizedBox(height: 24),

                        Text(
                          '🚀 Acciones Rápidas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🚀 Acciones rápidas con navegación real
                        _buildQuickActionsGrid(context),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔔 WIDGET DE NOTIFICACIONES DINÁMICO
  Widget _buildNotificationIcon(String companyId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminOrdersScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 28,
              ),
            ),
            if (pendingCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    pendingCount > 99 ? '99+' : pendingCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// 📊 RESUMEN DINÁMICO CON DATOS REALES
  Widget _buildDynamicSummary(String companyId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 📊 Pedidos de hoy
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .collection('orders')
                .where('createdAt', isGreaterThanOrEqualTo: _getTodayStart())
                .snapshots(),
            builder: (context, snapshot) {
              final todayOrders = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildSummaryItem('Pedidos Hoy', todayOrders.toString(), Icons.receipt_long);
            },
          ),

          // 💰 TOTAL ACUMULADO (CAMBIO ESPECÍFICO SOLICITADO)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .collection('orders')
                .where('status', whereIn: ['approved', 'sent', 'completed'])
                .snapshots(),
            builder: (context, snapshot) {
              double totalAccumulated = 0.0;
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Verificar tanto 'total' como 'totalAmount' para compatibilidad
                  final amount = (data['total'] ?? data['totalAmount'] ?? 0.0) as num;
                  totalAccumulated += amount.toDouble();
                }
              }
              return _buildSummaryItem('Total', '€${totalAccumulated.toStringAsFixed(0)}', Icons.euro);
            },
          ),

          // 👥 Empleados activos
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('companies')
                .doc(companyId)
                .collection('employees')
                .where('isActive', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              final activeEmployees = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return _buildSummaryItem('Empleados', activeEmployees.toString(), Icons.people);
            },
          ),
        ],
      ),
    );
  }

  /// 📝 PEDIDOS PENDIENTES DINÁMICOS
  Widget _buildDynamicPendingOrders(String companyId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Error al cargar pedidos pendientes'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pendingOrders = snapshot.data?.docs ?? [];

        if (pendingOrders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
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
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppTheme.successColor.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Todo al día!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No hay pedidos pendientes de aprobación',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.pending_actions, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pedidos Pendientes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        pendingOrders.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...pendingOrders.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return _buildDynamicPendingOrderItem(
                  context,
                  companyId,
                  doc.id,
                  data,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// 📝 ITEM DE PEDIDO PENDIENTE DINÁMICO
  Widget _buildDynamicPendingOrderItem(
    BuildContext context,
    String companyId,
    String orderId,
    Map<String, dynamic> orderData,
  ) {
    final orderNumber = orderData['orderNumber'] ?? 'N/A';
    final employeeName = orderData['employeeName'] ?? 'Empleado';
    final supplierName = orderData['supplierName'] ?? 'Proveedor';
    final totalAmount = (orderData['total'] ?? orderData['totalAmount'] ?? 0.0) as num;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$orderNumber - $employeeName',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$supplierName • €${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              // ✅ BOTÓN APROBAR FUNCIONAL
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.successColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _approveOrder(context, companyId, orderId),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ❌ BOTÓN RECHAZAR FUNCIONAL
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _rejectOrder(context, companyId, orderId),
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🚀 ACCIONES RÁPIDAS CON NAVEGACIÓN REAL
  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Nuevo Pedido',
                Icons.add_shopping_cart,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminOrdersScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Gestionar Empleados',
                Icons.people,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmployeesScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                'Ver Proveedores',
                Icons.business,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuppliersScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                'Configuración',
                Icons.settings,
                () {
                  // Cambiar a tab de configuración
                  final dashboardState = context.findAncestorStateOfType<_AdminDashboardScreenState>();
                  if (dashboardState != null) {
                    dashboardState.setState(() {
                      dashboardState._currentIndex = 4; // Índice de configuración
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔧 WIDGETS AUXILIARES
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🔧 FUNCIONES AUXILIARES
  DateTime _getTodayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// ✅ FUNCIÓN PARA APROBAR PEDIDO
  Future<void> _approveOrder(BuildContext context, String companyId, String orderId) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Aprobar Pedido'),
          content: const Text('¿Estás seguro de que quieres aprobar este pedido?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
              child: const Text('Aprobar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
          'approvedBy': context.read<RestauAuthProvider>().user?.uid,
        });

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pedido aprobado correctamente'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al aprobar pedido: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// ❌ FUNCIÓN PARA RECHAZAR PEDIDO
  Future<void> _rejectOrder(BuildContext context, String companyId, String orderId) async {
    final reasonController = TextEditingController();

    try {
      final reason = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rechazar Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Por qué rechazas este pedido?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Motivo del rechazo...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(reasonController.text.trim()),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              child: const Text('Rechazar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (reason != null && reason.isNotEmpty) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'rejected',
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectedBy': context.read<RestauAuthProvider>().user?.uid,
          'rejectionReason': reason,
        });

        if (context.mounted) Navigator.of(context).pop();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Pedido rechazado'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al rechazar pedido: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
