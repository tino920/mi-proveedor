import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../shared/models/supplier_model.dart'; // ✅ NUEVO
import '../../../../shared/models/product_model.dart'; // ✅ NUEVO
import '../../../suppliers/providers/suppliers_provider.dart'; // ✅ NUEVO
import '../../../orders/providers/orders_provider.dart';
import '../../../orders/presentation/screens/create_order_screen.dart'; // ✅ NUEVO
import '../../../orders/presentation/widgets/order_status_chip.dart';

/// 📋 PANTALLA DE HISTORIAL DE PEDIDOS PARA EMPLEADO
/// Muestra todos los pedidos del empleado con filtros, búsqueda y swipe to hide
class EmployeeHistoryScreen extends StatefulWidget {
  const EmployeeHistoryScreen({super.key});

  @override
  State<EmployeeHistoryScreen> createState() => _EmployeeHistoryScreenState();
}

class _EmployeeHistoryScreenState extends State<EmployeeHistoryScreen> {
  // 🔍 FILTROS Y BÚSQUEDA
  String _searchQuery = '';
  OrderStatus? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();

  // 👁️ PEDIDOS OCULTOS
  final Set<String> _hiddenOrderIds = <String>{};
  bool _showHiddenOrders = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final companyId = authProvider.companyId;
    
    // 🔧 FIX: Usar la misma lógica que en create_order_screen
    final employeeId = authProvider.user?.uid;

    print('🔍 HISTORIAL DEBUG:');
    print('CompanyId: $companyId');
    print('EmployeeId from user.uid: $employeeId');
    print('EmployeeId from currentUser.uid: ${authProvider.currentUser?.uid}');
    print('User email: ${authProvider.user?.email}');
    print('CurrentUser email: ${authProvider.currentUser?.email}');

    if (companyId == null || employeeId == null) {
      return _buildErrorState();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
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
                child: Column(
                  children: [
                    // 🔍 Barra de búsqueda y filtros
                    _buildSearchAndFilters(),

                    // 👁️ Toggle para mostrar/ocultar pedidos ocultos
                    if (_hiddenOrderIds.isNotEmpty) _buildHiddenOrdersToggle(),

                    // 📋 Lista de pedidos
                    Expanded(
                      child: _buildOrdersList(companyId, employeeId),
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

  // 🎨 HEADER DE LA PANTALLA
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
              Icons.history,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Mi Historial',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Botón de filtros
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () => _showFiltersDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  // 🔍 BARRA DE BÚSQUEDA Y FILTROS
  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Buscar pedidos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Filtros activos
          if (_selectedStatus != null || _selectedDateRange != null) ...[
            const SizedBox(height: 12),
            _buildActiveFilters(),
          ],
        ],
      ),
    );
  }

  // 👁️ TOGGLE PARA MOSTRAR PEDIDOS OCULTOS
  Widget _buildHiddenOrdersToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _showHiddenOrders ? Icons.visibility_off : Icons.visibility,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _showHiddenOrders 
                  ? 'Mostrando ${_hiddenOrderIds.length} pedidos ocultos'
                  : 'Tienes ${_hiddenOrderIds.length} pedidos ocultos',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: _showHiddenOrders,
            onChanged: (value) {
              setState(() {
                _showHiddenOrders = value;
              });
            },
            activeColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  // 🏷️ FILTROS ACTIVOS
  Widget _buildActiveFilters() {
    return Wrap(
      spacing: 8,
      children: [
        if (_selectedStatus != null)
          Chip(
            label: Text(_getStatusText(_selectedStatus!)),
            backgroundColor: _getStatusColor(_selectedStatus!).withOpacity(0.1),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => setState(() => _selectedStatus = null),
          ),
        if (_selectedDateRange != null)
          Chip(
            label: Text(_getDateRangeText(_selectedDateRange!)),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => setState(() => _selectedDateRange = null),
          ),
      ],
    );
  }

  // 📋 LISTA DE PEDIDOS ARREGLADA
  Widget _buildOrdersList(String companyId, String employeeId) {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        return StreamBuilder<List<Order>>(
          stream: ordersProvider.getOrdersStream(companyId),
          builder: (context, snapshot) {
            print('🔍 STREAM DEBUG:');
            print('ConnectionState: ${snapshot.connectionState}');
            print('HasError: ${snapshot.hasError}');
            print('Error: ${snapshot.error}');
            print('HasData: ${snapshot.hasData}');
            print('Data length: ${snapshot.data?.length ?? 0}');

            // 🔧 FIX: Si tiene datos, procesarlos aunque esté en waiting
            if (snapshot.hasError) {
              print('🚨 ERROR EN STREAM: ${snapshot.error}');
              return _buildErrorState();
            }

            // 🔧 FIX: Mostrar loading solo si no hay datos Y está en waiting
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando pedidos...'),
                  ],
                ),
              );
            }

            final allOrders = snapshot.data ?? [];
            print('📋 TODOS LOS PEDIDOS: ${allOrders.length}');
            
            // Debug: Mostrar algunos pedidos para verificar employeeId
            for (int i = 0; i < allOrders.length && i < 10; i++) {
              final order = allOrders[i];
              print('  📝 Pedido $i: #${order.orderNumber}');
              print('     EmployeeId en DB: "${order.employeeId}"');
              print('     Buscando: "$employeeId"');
              print('     Coincide: ${order.employeeId == employeeId}');
              print('     EmployeeName: ${order.employeeName}');
              print('     Status: ${order.status.name}');
              print('     Created: ${order.createdAt}');
            }

            final myOrders = allOrders
                .where((order) => order.employeeId == employeeId)
                .toList();

            print('📝 MIS PEDIDOS: ${myOrders.length}');

            // 👁️ FILTRAR PEDIDOS OCULTOS/VISIBLES
            final List<Order> filteredByVisibility;
            if (_showHiddenOrders) {
              // Mostrar solo pedidos ocultos
              filteredByVisibility = myOrders
                  .where((order) => _hiddenOrderIds.contains(order.id))
                  .toList();
            } else {
              // Mostrar solo pedidos visibles
              filteredByVisibility = myOrders
                  .where((order) => !_hiddenOrderIds.contains(order.id))
                  .toList();
            }

            // Aplicar filtros adicionales
            final filteredOrders = _applyFilters(filteredByVisibility);
            print('🔍 PEDIDOS FILTRADOS: ${filteredOrders.length}');

            // Si no hay pedidos en la empresa
            if (allOrders.isEmpty) {
              return _buildEmptyState('No hay pedidos en la empresa');
            }

            // Si no hay pedidos del empleado
            if (myOrders.isEmpty) {
              return _buildEmptyStateWithDebug(
                'No tienes pedidos aún',
                'Total en empresa: ${allOrders.length}\nBuscando employeeId: $employeeId',
                allOrders,
                employeeId,
              );
            }

            // Si no hay pedidos que coincidan con filtros
            if (filteredOrders.isEmpty) {
              final message = _showHiddenOrders 
                  ? 'No hay pedidos ocultos que coincidan con los filtros'
                  : 'No hay pedidos que coincidan con los filtros\n(Tienes ${myOrders.length} pedidos sin filtrar)';
              return _buildEmptyState(message);
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildSwipeableOrderCard(order);
                },
              ),
            );
          },
        );
      },
    );
  }

  // 📄 TARJETA DE PEDIDO CON SWIPE
  Widget _buildSwipeableOrderCard(Order order) {
    final bool isDismissible = !_showHiddenOrders;
    return Dismissible(
      key: Key(order.id),
      direction: isDismissible ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Ocultar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Agregar haptic feedback
        HapticFeedback.lightImpact();
        
        // Mostrar confirmación
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ocultar pedido'),
            content: Text('¿Quieres ocultar el pedido #${order.orderNumber}?\n\nPodrás mostrarlo nuevamente desde la opción "Pedidos ocultos".'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ocultar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Agregar a pedidos ocultos
        setState(() {
          _hiddenOrderIds.add(order.id);
        });

        // Mostrar SnackBar con opción de deshacer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido #${order.orderNumber} oculto'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Deshacer',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  _hiddenOrderIds.remove(order.id);
                });
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      },
      child: _buildOrderCard(order),
    );
  }

  // 📄 TARJETA DE PEDIDO (ORIGINAL)
  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('dd MMM yyyy - HH:mm', 'es_ES');
    
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
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del pedido
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Pedido #${order.orderNumber}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                                // Opcional: para que el texto no se parta en dos líneas
                                // y muestre "..." si es muy largo.
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (_hiddenOrderIds.contains(order.id)) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Oculto',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.status),
                ],
              ),

              const SizedBox(height: 12),

              // Proveedor
              Row(
                children: [
                  const Icon(Icons.store, size: 16, color: AppTheme.secondaryTextColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.supplierName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Productos
              Row(
                children: [
                  const Icon(Icons.shopping_bag, size: 16, color: AppTheme.secondaryTextColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.items.length} productos',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Total y acciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: €${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      if (order.status == OrderStatus.draft)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _editOrder(order),
                        ),
                      // ✅ NUEVO: Botón Reenviar para pedidos enviados
                      if (order.status == OrderStatus.sent || order.status == OrderStatus.approved)
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 20, color: AppTheme.primaryColor),
                          onPressed: () => _reorderOrder(order),
                          tooltip: 'Reenviar pedido',
                        ),
                      IconButton(
                        icon: const Icon(Icons.visibility, size: 20),
                        onPressed: () => _showOrderDetails(order),
                      ),
                      if (_showHiddenOrders)
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20, color: Colors.orange),
                          onPressed: () => _unhideOrder(order),
                          tooltip: 'Mostrar pedido',
                        ),
                    ],
                  ),
                ],
              ),

              // Hint de swipe solo para pedidos visibles
              if (!_showHiddenOrders && !_hiddenOrderIds.contains(order.id)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.swipe_left,
                      size: 14,
                      color: AppTheme.secondaryTextColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Desliza para ocultar',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryTextColor.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],

              // Notas si existen
              if (order.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.notes!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 👁️ MOSTRAR PEDIDO OCULTO
  void _unhideOrder(Order order) {
    setState(() {
      _hiddenOrderIds.remove(order.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido #${order.orderNumber} ahora es visible'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 🔍 DIÁLOGO DE FILTROS
  void _showFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Pedidos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtro por estado
              const Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedStatus == null,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = null);
                      Navigator.pop(context);
                    },
                  ),
                  ...OrderStatus.values.map((status) => FilterChip(
                    label: Text(_getStatusText(status)),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = selected ? status : null);
                      Navigator.pop(context);
                    },
                  )),
                ],
              ),

              const SizedBox(height: 16),

              // Filtro por fecha
              const Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(Icons.date_range),
                      label: Text(_selectedDateRange == null 
                          ? 'Seleccionar rango' 
                          : _getDateRangeText(_selectedDateRange!)),
                    ),
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _selectedDateRange = null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Opciones de pedidos ocultos
              const Text('Pedidos ocultos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_hiddenOrderIds.isNotEmpty)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _hiddenOrderIds.clear();
                          });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.visibility),
                        label: const Text('Mostrar todos'),
                      ),
                    ),
                  ],
                ),
              if (_hiddenOrderIds.isEmpty)
                const Text(
                  'No hay pedidos ocultos',
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 12,
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
        ],
      ),
    );
  }

  // 📅 SELECCIONAR RANGO DE FECHAS
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      Navigator.pop(context);
    }
  }

  // 🔍 APLICAR FILTROS
  List<Order> _applyFilters(List<Order> orders) {
    var filtered = orders;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final searchLower = _searchQuery.toLowerCase();
        return order.orderNumber.toLowerCase().contains(searchLower) ||
               order.supplierName.toLowerCase().contains(searchLower) ||
               (order.notes?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Filtrar por estado
    if (_selectedStatus != null) {
      filtered = filtered.where((order) => order.status == _selectedStatus).toList();
    }

    // Filtrar por rango de fechas
    if (_selectedDateRange != null) {
      filtered = filtered.where((order) {
        final orderDate = order.createdAt;
        return orderDate.isAfter(_selectedDateRange!.start) &&
               orderDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    // Ordenar por fecha (más recientes primero)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  // 📄 MOSTRAR DETALLES DEL PEDIDO
  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text('Pedido #${order.orderNumber}'),
            if (_hiddenOrderIds.contains(order.id)) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Oculto',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información básica
              _buildDetailRow('Proveedor:', order.supplierName),
              _buildDetailRow('Estado:', _getStatusText(order.status)),
              _buildDetailRow('Fecha:', DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)),
              _buildDetailRow('Total:', '€${order.total.toStringAsFixed(2)}'),

              if (order.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                const Text('Notas:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(order.notes!),
              ],

              const SizedBox(height: 16),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Lista de productos
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('${item.quantity} ${item.unit} × €${item.unitPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    Text('€${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          if (_hiddenOrderIds.contains(order.id))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _unhideOrder(order);
              },
              child: const Text('Mostrar pedido'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          // ✅ NUEVO: Botón Reenviar en modal de detalles
          if (order.status == OrderStatus.sent || order.status == OrderStatus.approved)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _reorderOrder(order);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reenviar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          if (order.status == OrderStatus.draft)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _editOrder(order);
              },
              child: const Text('Editar'),
            ),
        ],
      ),
    );
  }

  // 📝 EDITAR PEDIDO
  void _editOrder(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad de edición próximamente')),
    );
  }

  // 🔄 REENVIAR PEDIDO (NUEVA FUNCIONALIDAD)
  Future<void> _reorderOrder(Order originalOrder) async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.refresh, color: AppTheme.primaryColor),
            SizedBox(width: 12),
            Text('Reenviar Pedido'),
          ],
        ),
        content: Column(
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
                    'Proveedor: ${originalOrder.supplierName}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('Productos: ${originalOrder.items.length}'),
                  Text('Total original: €${originalOrder.total.toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Se creará un nuevo pedido con los mismos productos que podrás modificar antes de enviar.',
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
            ),
          ],
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

      // Crear nuevo pedido borrador
      final newOrder = await ordersProvider.createDraftOrder(
        companyId: authProvider.companyId!,
        employeeId: authProvider.user!.uid,
        employeeName: authProvider.currentUser?.name ?? 'Usuario',
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
          createdAt: DateTime.now(), // ✅ AÑADIDO
          updatedAt: DateTime.now(), // ✅ AÑADIDO
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
                child: Text('Pedido recreado con ${originalOrder.items.length} productos'),
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

  // 🔧 WIDGETS AUXILIARES
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState([String? customMessage]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            customMessage ?? 'No hay pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tus pedidos aparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // 🐛 EMPTY STATE CON DEBUG MEJORADO
  Widget _buildEmptyStateWithDebug(String title, String subtitle, List<Order> allOrders, String searchingEmployeeId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: AppTheme.secondaryTextColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          // 🐛 DEBUG: Mostrar los employeeIds para debug
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🐛 DEBUG INFO:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text('Tu employeeId: "$searchingEmployeeId"'),
                const SizedBox(height: 8),
                const Text('EmployeeIds en pedidos de la empresa:'),
                ...allOrders.take(10).map((order) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 2),
                  child: Text(
                    '• "${order.employeeId}" (${order.employeeName}) [${order.orderNumber}]',
                    style: const TextStyle(fontSize: 11),
                  ),
                )),
                if (allOrders.length > 10) 
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2),
                    child: Text('... y ${allOrders.length - 10} pedidos más'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Copiar al clipboard para debugging
                    print('=== DEBUG COMPLETO ===');
                    print('Searching for: "$searchingEmployeeId"');
                    for (var order in allOrders) {
                      print('Order: ${order.orderNumber}, Employee: "${order.employeeId}" (${order.employeeName})');
                    }
                    print('=== FIN DEBUG ===');
                  },
                  child: const Text('Imprimir Debug Completo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
            'Error al cargar pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta nuevamente más tarde',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 FUNCIONES AUXILIARES
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return 'Borrador';
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.approved:
        return 'Aprobado';
      case OrderStatus.rejected:
        return 'Rechazado';
      case OrderStatus.sent:
        return 'Enviado';
      default:
        return 'Desconocido';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.draft:
        return Colors.grey;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.approved:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.sent:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDateRangeText(DateTimeRange range) {
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }
}
