import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import '../../providers/suppliers_provider.dart';
import '../widgets/add_supplier_dialog.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../products/presentation/screens/supplier_products_screen.dart';
// Asegúrate de que la ruta sea correcta según la estructura de tu proyecto
import '/shared/widgets/supplier_icon_widget.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SuppliersProvider(),
      child: const _SuppliersScreenContent(),
    );
  }
}

class _SuppliersScreenContent extends StatefulWidget {
  const _SuppliersScreenContent();

  @override
  State<_SuppliersScreenContent> createState() => _SuppliersScreenContentState();
}

class _SuppliersScreenContentState extends State<_SuppliersScreenContent> {
  Stream<List<Supplier>>? _suppliersStream;
  String? _companyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<RestauAuthProvider>(context);
    final newCompanyId = authProvider.companyId;

    if (newCompanyId != null && newCompanyId != _companyId) {
      _companyId = newCompanyId;
      final suppliersProvider = Provider.of<SuppliersProvider>(context, listen: false);
      _suppliersStream = suppliersProvider.getSuppliersStream(_companyId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<RestauAuthProvider>(context);

    if (_companyId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Proveedores')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando empresa...'),
            ],
          ),
        ),
      );
    }

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
            'Proveedores',
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
      floatingActionButton: authProvider.isAdmin
          ? _AnimatedFAB(
              onPressed: () => _showAddSupplierDialog(context, _companyId!),
              icon: Icons.add,
              heroTag: "add_supplier",
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Column(
          children: [
            // Header con título e información
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                children: [
                  const SupplierIconWidget(size: 80), // Se quita el Icon y se pone tu widget
                  const SizedBox(height: 16),
                  const Text(
                    'Gestión de Proveedores',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.isAdmin
                        ? 'Administra tus proveedores y sus productos'
                        : 'Visualiza los proveedores disponibles',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: StreamBuilder<List<Supplier>>(
                  stream: _suppliersStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.errorColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar proveedores',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(color: AppTheme.secondaryTextColor),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
      
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppTheme.primaryColor),
                            SizedBox(height: 16),
                            Text(
                              'Cargando proveedores...',
                              style: TextStyle(color: AppTheme.secondaryTextColor),
                            ),
                          ],
                        ),
                      );
                    }
      
                    final suppliers = snapshot.data ?? [];
      
                    if (suppliers.isEmpty) {
                      return _buildEmptyState(context, _companyId!, authProvider.isAdmin);
                    }
      
                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      color: AppTheme.primaryColor,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                        itemCount: suppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = suppliers[index];
                          return _SupplierCard(
                            supplier: supplier,
                            companyId: _companyId!,
                            isAdmin: authProvider.isAdmin,
                          );
                        },
                      ),
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

  Widget _buildEmptyState(BuildContext context, String companyId, bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.local_shipping,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No hay proveedores',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isAdmin
                  ? 'Añade tu primer proveedor para empezar a gestionar pedidos'
                  : 'El administrador debe añadir proveedores para crear pedidos',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (isAdmin)
              GradientButton(
                text: 'Añadir Primer Proveedor',
                icon: Icons.add,
                onPressed: () => _showAddSupplierDialog(context, companyId),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddSupplierDialog(BuildContext context, String companyId) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: Provider.of<SuppliersProvider>(context, listen: false),
        child: AddSupplierDialog(companyId: companyId),
      ),
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToProducts(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: supplier.imageUrl != null && supplier.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: supplier.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.business,
                      color: AppTheme.primaryColor,
                      size: 40,
                    ),
                  )
                      : const Icon(
                    Icons.business,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (supplier.description != null && supplier.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        supplier.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (supplier.phone != null && supplier.phone!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            supplier.phone!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (supplier.email != null && supplier.email!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.email,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 6),
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
                      ),
                    ],
                    if (supplier.deliveryDays.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: supplier.deliveryDays.map((day) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getDayAbbreviation(day),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAdmin)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppTheme.secondaryTextColor),
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
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.secondaryTextColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDayAbbreviation(String day) {
    final abbreviations = {
      'Lunes': 'Lun', 'Martes': 'Mar', 'Miércoles': 'Mié', 'Jueves': 'Jue',
      'Viernes': 'Vie', 'Sábado': 'Sáb', 'Domingo': 'Dom',
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
        title: Text('⚠️ Eliminar Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Eliminar "${supplier.name}"?'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text('⚠️ ATENCIÓN: Esto también eliminará:'),
                  Text('🗑️ Todos los productos asociados'),
                  Text('📸 Todas las imágenes relacionadas'),
                  Text('📋 Esta acción NO se puede deshacer'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );

              final provider = Provider.of<SuppliersProvider>(context, listen: false);
              final result = await provider.deleteSupplier(
                companyId: companyId,
                supplierId: supplier.id,
                imageUrl: supplier.imageUrl,
              );

              if (context.mounted) Navigator.of(context).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['success']
                        ? 'Proveedor eliminado correctamente'
                        : result['error'] ?? 'Error al eliminar proveedor'),
                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ✨ FAB ANIMADO CON EFECTOS VISUALES
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? heroTag;

  const _AnimatedFAB({
    required this.onPressed,
    required this.icon,
    this.heroTag,
  });

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.25, // 90 grados
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Animaciones simultáneas
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    
    _rotationController.forward().then((_) {
      _rotationController.reverse();
    });
    
    // Llamar función original
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6B73FF),
                    Color(0xFF4ECDC4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6B73FF).withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: widget.heroTag,
                onPressed: _handleTap,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                child: Icon(
                  widget.icon,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
