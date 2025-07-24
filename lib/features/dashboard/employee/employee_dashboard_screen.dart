import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import '../../orders/presentation/screens/create_order_screen.dart';
import '../../orders/presentation/screens/employee_orders_screen.dart';
import '../../orders/presentation/widgets/order_status_chip.dart';
import '../../suppliers/providers/suppliers_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/order_model.dart';
// ✅ IMPORTAMOS LA PANTALLA COMPLETA DE PERFIL
import '../../profile/presentation/screens/employee_profile_screen.dart';
import '../../profile/presentation/screens/employee_history_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  int _currentIndex = 0;

  // ✅ AQUÍ USAMOS LA PANTALLA COMPLETA DE PERFIL
  final List<Widget> _screens = [
    const EmployeeHomeScreen(),
    const EmployeeOrdersScreen(),
    const EmployeeHistoryScreen(), // Pantalla de historial dedicada
    const EmployeeProfileScreen(), // ✅ PANTALLA COMPLETA DE PERFIL
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ✨ PANTALLA DE INICIO MEJORADA CON DATOS REALES
class EmployeeHomeScreen extends StatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  State<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends State<EmployeeHomeScreen> {
  late Stream<List<Supplier>> _suppliersStream;
  late Stream<List<Order>> _ordersStream;
  String? _companyId;
  String? _employeeId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final newCompanyId = authProvider.companyId;
    final newEmployeeId = authProvider.user?.uid;

    if (newCompanyId != null && newCompanyId != _companyId) {
      _companyId = newCompanyId;
      _employeeId = newEmployeeId;

      final suppliersProvider = Provider.of<SuppliersProvider>(context, listen: false);
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

      _suppliersStream = suppliersProvider.getSuppliersStream(_companyId!);
      _ordersStream = ordersProvider.getOrdersStream(_companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final userName = authProvider.userData?['name'] ?? 'Empleado';
    final companyName = authProvider.companyData?['name'] ?? 'Mi Restaurante';

    // Manejo cuando no hay companyId
    if (_companyId == null || _companyId!.isEmpty) {
      return _buildErrorState(authProvider);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 🎨 HEADER MEJORADO CON GRADIENTE
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
                          Icons.person,
                          color: Colors.white,
                          size: 28,
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              companyName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 🔔 NOTIFICACIONES CON BADGE REAL
                      StreamBuilder<List<Order>>(
                        stream: _ordersStream,
                        builder: (context, snapshot) {
                          final newNotifications = snapshot.data?.where((order) =>
                          order.employeeId == _employeeId &&
                              (order.status == OrderStatus.approved || order.status == OrderStatus.rejected) &&
                              !order.viewedByEmployee
                          ).toList() ?? [];

                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications, color: Colors.white, size: 26),
                                onPressed: () async {
                                  final ordersProvider = context.read<OrdersProvider>();
                                  if (_companyId != null && _employeeId != null) {
                                    await ordersProvider.markNotificationsAsViewed(_companyId!, _employeeId!);
                                  }
                                  setState(() {
                                    final dashboardState = context.findAncestorStateOfType<_EmployeeDashboardScreenState>();
                                    dashboardState?.setState(() {
                                      dashboardState._currentIndex = 2;
                                    });
                                  });
                                },
                              ),
                              if (newNotifications.isNotEmpty)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: Color(0xFFFF6B6B), shape: BoxShape.circle),
                                    child: Text(
                                      '${newNotifications.length}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 📊 ESTADÍSTICAS REALES DEL EMPLEADO
                  StreamBuilder<List<Order>>(
                    stream: _ordersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingStats();
                      }

                      final allOrders = snapshot.data ?? [];
                      final myOrders = allOrders.where((order) => order.employeeId == _employeeId).toList();
                      final thisMonthOrders = myOrders.where((order) {
                        final now = DateTime.now();
                        return order.createdAt.year == now.year && order.createdAt.month == now.month;
                      }).toList();

                      final monthlyTotal = thisMonthOrders.fold<double>(0, (sum, order) => sum + order.total);
                      final pendingCount = myOrders.where((order) => order.status == OrderStatus.pending).length;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('Este Mes', '${thisMonthOrders.length}', Icons.receipt_long),
                            _buildSummaryItem('Total', '€${monthlyTotal.toStringAsFixed(0)}', Icons.euro),
                            _buildSummaryItem('Pendientes', '$pendingCount', Icons.pending),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '¿Qué necesitas pedir hoy?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // 📱 CONTENIDO PRINCIPAL MEJORADO
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

                      // 🛒 BOTÓN PRINCIPAL MEJORADO PARA CREAR PEDIDO
                      StreamBuilder<List<Supplier>>(
                        stream: _suppliersStream,
                        builder: (context, snapshot) {
                          final suppliers = snapshot.data ?? [];
                          return _buildCreateOrderButton(context, suppliers);
                        },
                      ),

                      const SizedBox(height: 32),

                      // 📋 PEDIDOS RECIENTES REALES
                      Text(
                        'Mis Pedidos Recientes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<List<Order>>(
                        stream: _ordersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingOrders();
                          }

                          if (snapshot.hasError) {
                            return _buildErrorOrders();
                          }

                          final allOrders = snapshot.data ?? [];
                          final myRecentOrders = allOrders
                              .where((order) => order.employeeId == _employeeId)
                              .take(3)
                              .toList();

                          if (myRecentOrders.isEmpty) {
                            return _buildEmptyOrders();
                          }

                          return Column(
                            children: myRecentOrders.map((order) =>
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildRecentOrderCard(context, order),
                              ),
                            ).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // 🏭 PROVEEDORES FAVORITOS REALES
                      Text(
                        'Proveedores Disponibles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      StreamBuilder<List<Supplier>>(
                        stream: _suppliersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return _buildLoadingSuppliers();
                          }

                          if (snapshot.hasError) {
                            return _buildErrorSuppliers();
                          }

                          final suppliers = snapshot.data ?? [];

                          if (suppliers.isEmpty) {
                            return _buildEmptySuppliers();
                          }

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                            itemCount: suppliers.length > 4 ? 4 : suppliers.length,
                            itemBuilder: (context, index) {
                              return _EmployeeSupplierCard(
                                supplier: suppliers[index],
                                onTap: () => _navigateToCreateOrder(context, suppliers[index]),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [RESTO DE MÉTODOS AUXILIARES - MANTENGO LOS MISMOS]
  Widget _buildErrorState(RestauAuthProvider authProvider) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_outlined, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No estás vinculado a una empresa',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Para poder crear pedidos, necesitas estar vinculado a una empresa. Contacta con tu administrador.',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Recargar',
                  icon: Icons.refresh,
                  onPressed: () async => await authProvider.refreshUserData(),
                  gradient: const LinearGradient(colors: [Colors.white, Color(0xFFF0F0F0)]),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async => await authProvider.logout(),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildCreateOrderButton(BuildContext context, List<Supplier> suppliers) {
    return GestureDetector(
      onTap: () {
        if (suppliers.isNotEmpty) {
          _showSupplierSelector(context, suppliers);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay proveedores disponibles para crear un pedido.')),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear Nuevo Pedido',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suppliers.isNotEmpty ? 'Toca para comenzar' : 'No hay proveedores disponibles',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, Order order) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.pending;
        statusText = 'Pendiente';
        break;
      case OrderStatus.approved:
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'Aprobado';
        break;
      case OrderStatus.rejected:
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        statusText = 'Rechazado';
        break;
      case OrderStatus.sent:
        statusColor = AppTheme.primaryColor;
        statusIcon = Icons.send;
        statusText = 'Enviado';
        break;
      default:
        statusColor = AppTheme.secondaryTextColor;
        statusIcon = Icons.help;
        statusText = 'Desconocido';
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () {
          // Navegar a detalles del pedido
        },
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.supplierName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.orderNumber,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryTextColor),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${order.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
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

  // Estados de carga
  Widget _buildLoadingStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(3, (index) =>
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOrders() {
    return Column(
      children: List.generate(3, (index) =>
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSuppliers() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no has hecho pedidos',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer pedido usando el botón de arriba',
            style: TextStyle(
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySuppliers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.business_outlined,
            size: 48,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores disponibles',
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'El administrador debe añadir proveedores',
            style: TextStyle(
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOrders() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor),
          SizedBox(width: 12),
          Text('Error al cargar pedidos'),
        ],
      ),
    );
  }

  Widget _buildErrorSuppliers() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.errorColor),
          SizedBox(width: 12),
          Text('Error al cargar proveedores'),
        ],
      ),
    );
  }

  // Navegación
  void _showSupplierSelector(BuildContext context, List<Supplier> suppliers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Selecciona un Proveedor',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.business, color: Colors.white),
                      ),
                      title: Text(supplier.name),
                      subtitle: supplier.description != null
                          ? Text(supplier.description!)
                          : null,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToCreateOrder(context, supplier);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateOrder(BuildContext context, Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateOrderScreen(supplier: supplier),
      ),
    );
  }
}

// 🎯 WIDGET MEJORADO PARA TARJETA DE PROVEEDOR
class _EmployeeSupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onTap;

  const _EmployeeSupplierCard({
    required this.supplier,
    required this.onTap,
  });

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
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                supplier.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (supplier.deliveryDays.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '${supplier.deliveryDays.length} días entrega',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
