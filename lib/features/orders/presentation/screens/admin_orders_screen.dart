import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../../shared/models/product_model.dart'; // ✅ NUEVO
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../providers/orders_provider.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import '../widgets/order_status_chip.dart';
import '../widgets/order_approval_dialog.dart';
import '../widgets/order_pdf_actions_dialog.dart';
import 'create_order_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _searchQuery = '';
  Stream<List<Order>>? _ordersStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      if (authProvider.companyId != null) {
        final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
        setState(() {
          _ordersStream = ordersProvider.getOrdersStreamForAdmin(authProvider.companyId!);
        });
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(() { setState(() {}); });
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B73FF), Color(0xFF129793)], // ← Estos colores
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Gestión de Pedidos',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        floatingActionButton: Consumer<SuppliersProvider>(
          builder: (context, suppliersProvider, _) {
            final authProvider = Provider.of<RestauAuthProvider>(context);
            final companyId = authProvider.companyId;

            if (companyId == null) return const SizedBox.shrink();

            return StreamBuilder<List<Supplier>>(
              stream: suppliersProvider.getSuppliersStream(companyId),
              builder: (context, snapshot) {
                final suppliers = snapshot.data ?? [];
                if (suppliers.isEmpty) return const SizedBox.shrink();

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.buttonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showAdminQuickOrderDialog(context, suppliers);
                    },
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    heroTag: 'admin_create_order_fab',
                    child: const Icon(
                      Icons.add_shopping_cart,
                      size: 28,
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Administrar Pedidos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Gestiona y supervisa todos los pedidos',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppTheme.textColor),
                        decoration: const InputDecoration(
                          hintText: 'Buscar pedidos...',
                          hintStyle: TextStyle(color: AppTheme.secondaryTextColor),
                          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: AppTheme.dividerColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: Colors.transparent,
                        tabAlignment: TabAlignment.start,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        tabs: [
                          _buildStyledTab(0, 'Pendientes', Colors.amber[700]!),
                          _buildStyledTab(1, 'Aprobados', AppTheme.successColor),
                          _buildStyledTab(3, 'Enviados', Colors.blueGrey[400]!),
                          _buildStyledTab(3, 'Todos', AppTheme.primaryColor),
                          _buildStyledTab(4, 'Rechazados', AppTheme.errorColor),

                        ],
                      ),
                    ),
                    Expanded(
                      child: Consumer<OrdersProvider>(
                        builder: (context, ordersProvider, _) {
                          if (_ordersStream == null) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryColor,
                              ),
                            );
                          }
                          return StreamBuilder<List<Order>>(
                            stream: _ordersStream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting && ordersProvider.allOrders.isEmpty) {
                                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }
                              if (ordersProvider.allOrders.isEmpty) {
                                return _buildEmptyList();
                              }
                              return TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildOrdersList(ordersProvider.pendingOrders),
                                  _buildOrdersList(ordersProvider.approvedOrders),
                                  _buildOrdersList(ordersProvider.sentOrders),
                                  _buildOrdersList(ordersProvider.allOrders),
                                  _buildOrdersList(ordersProvider.rejectedOrders),


                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledTab(int index, String text, Color color) {
    final isSelected = _tabController.index == index;
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(isSelected ? 1.0 : 0.6),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: text == 'Pendientes'
            ? Consumer<OrdersProvider>(
          builder: (context, ordersProvider, _) {
            final pendingCount = ordersProvider.pendingOrders.length;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                if (pendingCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pendingCount.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        )
            : Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.receipt_long_outlined : Icons.search_off,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'No hay pedidos en esta categoría' : 'No se encontraron pedidos',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textColor,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Intenta con otros términos de búsqueda',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAdminQuickOrderDialog(BuildContext context, List<Supplier> suppliers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crear Pedido (Admin)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        Text(
                          'Crear pedido como administrador',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: suppliers.length,
                itemBuilder: (context, index) {
                  final supplier = suppliers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateOrderScreen(supplier: supplier),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: supplier.imageUrl != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    supplier.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.store,
                                        color: AppTheme.primaryColor,
                                        size: 24,
                                      );
                                    },
                                  ),
                                )
                                    : const Icon(
                                  Icons.store,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      supplier.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textColor,
                                      ),
                                    ),
                                    if (supplier.phone != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        supplier.phone!,
                                        style: const TextStyle(
                                          color: AppTheme.secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppTheme.primaryColor.withOpacity(0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    final filteredOrders = orders.where((order) {
      if (_searchQuery.isEmpty) return true;
      return order.orderNumber.toLowerCase().contains(_searchQuery) ||
          order.employeeName.toLowerCase().contains(_searchQuery) ||
          order.supplierName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredOrders.isEmpty) {
      return _buildEmptyList();
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<OrdersProvider>().getOrdersStreamForAdmin(context.read<RestauAuthProvider>().companyId!),
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: AppTheme.primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'por ${order.employeeName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusChip(status: order.status),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppTheme.secondaryTextColor),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDeleteOrder(context, order);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppTheme.errorColor),
                            const SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.supplierName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor,
                            ),
                          ),
                          Text(
                            '${order.items.length} productos',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '€${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16.0,
                runSpacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.secondaryTextColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Creado ${_getTimeAgo(order.createdAt)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (order.isApproved && order.approvedAt != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Aprobado ${_getTimeAgo(order.approvedAt!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (order.canBeApproved || order.canBeRejected || order.canBeSent ||
                  order.status == OrderStatus.pending || order.status == OrderStatus.approved ||
                  order.status == OrderStatus.sent) ...[const SizedBox(height: 16),
                const Divider(color: AppTheme.dividerColor),
                const SizedBox(height: 8),
                _buildActionButtons(order),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(Order order) {
    return Row(
      children: [
        if (order.canBeApproved || order.canBeRejected) ...[
          // PEDIDOS PENDIENTES: Mostrar Aprobar/Rechazar
          if (order.canBeRejected) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectOrder(order, isFromBottomSheet: false),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (order.canBeApproved) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _approveOrder(order, isFromBottomSheet: false),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ] else if (order.canBeSent) ...[
          // PEDIDOS APROBADOS: Mostrar Editar + Enviar
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _editOrder(order),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _sendOrder(order, isFromBottomSheet: false),
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Enviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ] else if (order.status == OrderStatus.sent) ...[
          // SOLO PEDIDOS ENVIADOS: Mostrar Reenviar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _reorderOrder(order),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reenviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOrderDetailsBottomSheet(order),
    );
  }

  Future<void> _confirmDeleteOrder(BuildContext context, Order order) async {
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar permanentemente el pedido #${order.orderNumber}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await ordersProvider.deleteOrder(
        companyId: order.companyId,
        orderId: order.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result['success']
                    ? 'Pedido eliminado correctamente'
                    : 'Error al eliminar el pedido: ${result['error']}'
            ),
            backgroundColor: result['success'] ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }

  // 📝 NUEVO: EDITAR PEDIDO EXISTENTE
  Future<void> _editOrder(Order order) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener datos necesarios
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final suppliersProvider = Provider.of<SuppliersProvider>(context, listen: false);

      // Buscar el proveedor del pedido
      final suppliers = await suppliersProvider.getSuppliersStream(authProvider.companyId!).first;
      final supplier = suppliers.firstWhere(
        (s) => s.id == order.supplierId,
        orElse: () => throw Exception('Proveedor no encontrado'),
      );

      // ✅ CARGAR PEDIDO EXISTENTE en el provider
      ordersProvider.loadOrderForEditing(order);

      // Cerrar loading
      Navigator.pop(context);

      // Navegar a pantalla de crear pedido en modo edición
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateOrderScreen(
            supplier: supplier,
            editingOrder: order, // ✅ PASAR PEDIDO PARA EDITAR
          ),
        ),
      );

      // Si se guardó correctamente, mostrar mensaje
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Pedido #${order.orderNumber} actualizado'),
                ),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      // Cerrar loading si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error al editar pedido: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildOrderDetailsBottomSheet(Order order) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'por ${order.employeeName}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OrderStatusChip(status: order.status),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection(
                    title: 'Proveedor',
                    icon: Icons.business,
                    content: order.supplierName,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailSection(
                    title: 'Productos (${order.items.length})',
                    icon: Icons.inventory_2,
                    content: '',
                  ),
                  const SizedBox(height: 12),
                  ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        if (item.imageUrl != null) ...[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Icon(Icons.inventory_2),
                                errorWidget: (context, url, error) => const Icon(Icons.inventory_2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.quantityText} × ${item.unitPriceText}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.secondaryTextColor,
                                ),
                              ),
                              if (item.notes != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.notes!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.secondaryTextColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          item.totalPriceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total del Pedido',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        Text(
                          '€${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      title: 'Notas del pedido',
                      icon: Icons.note,
                      content: order.notes!,
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (order.canBeApproved || order.canBeRejected || order.canBeSent) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: SafeArea(
                child: _buildBottomSheetActionButtons(order),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSheetActionButtons(Order order) {
    return Row(
      children: [
        if (order.canBeApproved || order.canBeRejected) ...[
          if (order.canBeRejected) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _rejectOrder(order, isFromBottomSheet: true),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Rechazar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (order.canBeApproved) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _approveOrder(order, isFromBottomSheet: true),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Aprobar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ] else if (order.status == OrderStatus.pending || order.status == OrderStatus.approved) ...[
          // ✅ BOTÓN EDITAR en modal de detalles
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar modal
                _editOrder(order);
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar Pedido'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ✅ MÉTODOS DE ACCIÓN CORREGIDOS - CON PARÁMETRO isFromBottomSheet
  Future<void> _approveOrder(Order order, {required bool isFromBottomSheet}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OrderApprovalDialog(
        order: order,
        isApproval: true,
      ),
    );

    if (result == true && mounted) {
      // ✅ SOLUCIÓN: Solo cerrar el bottom sheet si se abrió desde ahí
      if (isFromBottomSheet) {
        Navigator.of(context).pop(); // Cierra solo el bottom sheet de detalles
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido ${order.orderNumber} aprobado'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rejectOrder(Order order, {required bool isFromBottomSheet}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OrderApprovalDialog(
        order: order,
        isApproval: false,
      ),
    );

    if (result == true && mounted) {
      // ✅ SOLUCIÓN: Solo cerrar el bottom sheet si se abrió desde ahí
      if (isFromBottomSheet) {
        Navigator.of(context).pop(); // Cierra solo el bottom sheet de detalles
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido ${order.orderNumber} rechazado'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendOrder(Order order, {required bool isFromBottomSheet}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => OrderPdfActionsDialog(order: order),
    );

    if (result == true && mounted) {
      // ✅ SOLUCIÓN: Solo cerrar el bottom sheet si se abrió desde ahí
      if (isFromBottomSheet) {
        Navigator.of(context).pop(); // Cierra solo el bottom sheet de detalles
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pedido ${order.orderNumber} enviado'),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 1) {
      return 'hace ${difference.inDays} días';
    }
    if (difference.inDays == 1) {
      return 'hace 1 día';
    }
    if (difference.inHours > 1) {
      return 'hace ${difference.inHours} horas';
    }
    if (difference.inHours == 1) {
      return 'hace 1 hora';
    }
    if (difference.inMinutes > 1) {
      return 'hace ${difference.inMinutes} minutos';
    }
    return 'hace un momento';
  }

  // 🔄 NUEVO: REENVIAR PEDIDO COMO ADMIN
  Future<void> _reorderOrder(Order originalOrder) async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Expanded(child: Text('Reenviar Pedido (Admin)')), // ✅ AÑADIDO Expanded
          ],
        ),
        content: SingleChildScrollView( // ✅ AÑADIDO SingleChildScrollView
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¿Quieres crear un nuevo pedido basado en el pedido #${originalOrder.orderNumber}?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Empleado original: ${originalOrder.employeeName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text('Proveedor: ${originalOrder.supplierName}'),
                    Text('Productos: ${originalOrder.items.length}'),
                    Text('Total original: €${originalOrder.total.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Se creará un nuevo pedido como administrador que podrás modificar antes de enviar.',
                style: TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reenviar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Obtener datos necesarios
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      final suppliersProvider = Provider.of<SuppliersProvider>(context, listen: false);

      // Buscar el proveedor del pedido original
      final suppliers = await suppliersProvider.getSuppliersStream(authProvider.companyId!).first;
      final supplier = suppliers.firstWhere(
        (s) => s.id == originalOrder.supplierId,
        orElse: () => throw Exception('Proveedor no encontrado'),
      );

      // ✅ ADMIN: Crear pedido como administrador
      final newOrder = await ordersProvider.createDraftOrder(
        companyId: authProvider.companyId!,
        employeeId: authProvider.user!.uid, // Admin como empleado
        employeeName: 'Admin - ${authProvider.currentUser?.name ?? 'Administrador'}',
        supplierId: supplier.id,
        supplierName: supplier.name,
      );

      if (newOrder == null) {
        throw Exception('Error al crear el pedido');
      }

      // Añadir todos los productos del pedido original
      for (final item in originalOrder.items) {
        // Crear un producto temporal desde el OrderItem
        final tempProduct = Product(
          id: item.productId,
          name: item.productName,
          price: item.unitPrice,
          unit: item.unit,
          category: item.category,
          supplierId: supplier.id,
          imageUrl: item.imageUrl,
          description: item.description,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ordersProvider.addProductToOrder(
          product: tempProduct,
          quantity: item.quantity,
          notes: item.notes,
        );
      }

      // Cerrar loading
      Navigator.pop(context);

      // Navegar a pantalla de crear pedido
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateOrderScreen(supplier: supplier),
        ),
      );

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Pedido recreado como Admin con ${originalOrder.items.length} productos'),
              ),
            ],
          ),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      // Cerrar loading si está abierto
      Navigator.pop(context);
      
      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Error al reenviar pedido: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
