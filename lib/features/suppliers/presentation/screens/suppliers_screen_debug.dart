import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/suppliers_provider.dart';
import '../widgets/add_supplier_dialog.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../products/presentation/screens/supplier_products_screen.dart';

class SuppliersScreenDebug extends StatefulWidget {
  const SuppliersScreenDebug({super.key});

  @override
  State<SuppliersScreenDebug> createState() => _SuppliersScreenDebugState();
}

class _SuppliersScreenDebugState extends State<SuppliersScreenDebug> {
  @override
  Widget build(BuildContext context) {
    print('🔍 SuppliersScreen: Construyendo pantalla');
    
    return Consumer<RestauAuthProvider>(
      builder: (context, authProvider, _) {
        print('🔍 AuthProvider state:');
        print('  - isLoading: ${authProvider.isLoading}');
        print('  - user: ${authProvider.user?.email}');
        print('  - companyId: ${authProvider.companyId}');
        print('  - userRole: ${authProvider.userRole}');
        
        // Loading state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando datos de usuario...'),
                ],
              ),
            ),
          );
        }
        
        // Usuario no autenticado
        if (authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Usuario no autenticado'),
                  Text('Por favor, inicia sesión'),
                ],
              ),
            ),
          );
        }
        
        // CompanyId no encontrado
        final companyId = authProvider.companyId;
        if (companyId == null || companyId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('No se encontró la empresa'),
                  const SizedBox(height: 8),
                  Text('User data: ${authProvider.userData}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => authProvider.logout(),
                    child: const Text('Cerrar Sesión'),
                  ),
                ],
              ),
            ),
          );
        }
        
        print('✅ CompanyId válido: $companyId');
        
        return ChangeNotifierProvider(
          create: (_) => SuppliersProvider(),
          child: Scaffold(
            backgroundColor: AppTheme.backgroundColor,
            appBar: AppBar(
              title: const Text('Proveedores'),
              actions: [
                // Solo mostrar botón añadir si es admin
                if (authProvider.isAdmin) ...[
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddSupplierDialog(context, companyId),
                  ),
                ],
                // Botón de debug
                IconButton(
                  icon: const Icon(Icons.bug_report),
                  onPressed: () => _showDebugInfo(context, authProvider),
                ),
              ],
            ),
            body: Consumer<SuppliersProvider>(
              builder: (context, provider, _) {
                print('🔍 SuppliersProvider state:');
                print('  - isLoading: ${provider.isLoading}');
                print('  - error: ${provider.error}');
                print('  - suppliers count: ${provider.suppliers.length}');
                
                return StreamBuilder<List<Supplier>>(
                  stream: provider.getSuppliersStream(companyId),
                  builder: (context, snapshot) {
                    print('🔍 StreamBuilder state:');
                    print('  - connectionState: ${snapshot.connectionState}');
                    print('  - hasError: ${snapshot.hasError}');
                    print('  - error: ${snapshot.error}');
                    print('  - hasData: ${snapshot.hasData}');
                    print('  - data length: ${snapshot.data?.length ?? 0}');
                    
                    // Loading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando proveedores...'),
                          ],
                        ),
                      );
                    }
                    
                    // Error
                    if (snapshot.hasError) {
                      print('❌ Error en StreamBuilder: ${snapshot.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: ${snapshot.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    final suppliers = snapshot.data ?? [];
                    print('✅ Proveedores cargados: ${suppliers.length}');
                    
                    // Empty state
                    if (suppliers.isEmpty) {
                      return _buildEmptyState(context, companyId, authProvider.isAdmin);
                    }
                    
                    // Lista de proveedores
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        return _SupplierCard(
                          supplier: supplier,
                          companyId: companyId,
                          isAdmin: authProvider.isAdmin,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(BuildContext context, String companyId, bool isAdmin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: AppTheme.secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay proveedores registrados',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin 
              ? 'Añade tu primer proveedor'
              : 'El administrador debe añadir proveedores',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (isAdmin) ...[
            ElevatedButton.icon(
              onPressed: () => _showAddSupplierDialog(context, companyId),
              icon: const Icon(Icons.add),
              label: const Text('Añadir Proveedor'),
            ),
          ],
        ],
      ),
    );
  }
  
  void _showAddSupplierDialog(BuildContext context, String companyId) {
    print('🔍 Mostrando diálogo añadir proveedor');
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: Provider.of<SuppliersProvider>(context, listen: false),
        child: AddSupplierDialog(companyId: companyId),
      ),
    );
  }
  
  void _showDebugInfo(BuildContext context, RestauAuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Usuario: ${authProvider.user?.email}'),
              Text('UID: ${authProvider.user?.uid}'),
              Text('Rol: ${authProvider.userRole}'),
              Text('CompanyId: ${authProvider.companyId}'),
              Text('Datos usuario: ${authProvider.userData}'),
              Text('Datos empresa: ${authProvider.companyData}'),
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
}

// Widget para mostrar cada proveedor (version debug)
class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final String companyId;
  final bool isAdmin;
  
  const _SupplierCard({
    required this.supplier,
    required this.companyId,
    required this.isAdmin,
  });
  
  @override
  Widget build(BuildContext context) {
    print('🔍 Renderizando SupplierCard: ${supplier.name}');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        onTap: () => _navigateToProducts(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagen del proveedor
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: supplier.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: supplier.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) {
                            print('❌ Error cargando imagen: $error');
                            return const Icon(
                              Icons.business,
                              color: AppTheme.primaryColor,
                              size: 30,
                            );
                          },
                        )
                      : const Icon(
                          Icons.business,
                          color: AppTheme.primaryColor,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del proveedor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (supplier.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        supplier.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (supplier.phone != null) ...[
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            supplier.phone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (supplier.email != null) ...[
                          const Icon(
                            Icons.email,
                            size: 14,
                            color: AppTheme.secondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              supplier.email!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (supplier.deliveryDays.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: supplier.deliveryDays.map((day) {
                          return Chip(
                            label: Text(
                              _getDayAbbreviation(day),
                              style: const TextStyle(fontSize: 10),
                            ),
                            padding: const EdgeInsets.all(0),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: AppTheme.successColor.withOpacity(0.1),
                            labelStyle: const TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Menú de opciones (solo para admin)
              if (isAdmin) ...[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditSupplierDialog(context);
                        break;
                      case 'delete':
                        _confirmDelete(context);
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
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getDayAbbreviation(String day) {
    final abbreviations = {
      'Lunes': 'Lun',
      'Martes': 'Mar',
      'Miércoles': 'Mié',
      'Jueves': 'Jue',
      'Viernes': 'Vie',
      'Sábado': 'Sáb',
      'Domingo': 'Dom',
    };
    return abbreviations[day] ?? day.substring(0, 3);
  }
  
  void _showEditSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: Provider.of<SuppliersProvider>(context, listen: false),
        child: AddSupplierDialog(
          companyId: companyId,
          supplier: supplier,
        ),
      ),
    );
  }
  
  void _navigateToProducts(BuildContext context) {
    print('🔍 Navegando a productos de: ${supplier.name}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierProductsScreen(supplier: supplier),
      ),
    );
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Proveedor'),
        content: Text('¿Estás seguro de que quieres eliminar a ${supplier.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              
              final provider = Provider.of<SuppliersProvider>(context, listen: false);
              final result = await provider.deleteSupplier(
                companyId: companyId,
                supplierId: supplier.id,
                imageUrl: supplier.imageUrl,
              );
              
              if (!result['success'] && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error'] ?? 'Error al eliminar'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
