import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/models/supplier_model.dart';
import '../../../suppliers/providers/suppliers_provider.dart';
import 'create_order_screen.dart';

class EmployeeOrdersScreen extends StatefulWidget {
  const EmployeeOrdersScreen({super.key});

  @override
  State<EmployeeOrdersScreen> createState() => _EmployeeOrdersScreenState();
}

class _EmployeeOrdersScreenState extends State<EmployeeOrdersScreen> {
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
      setState(() {
        _suppliersStream = suppliersProvider.getSuppliersStream(_companyId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Crear Pedido'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), // Ajuste de padding
              child: const Row(
                children: [
                  Icon(Icons.storefront, color: Colors.white, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona un Proveedor',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Toca una tarjeta para empezar tu pedido.',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                child: StreamBuilder<List<Supplier>>(
                  stream: _suppliersStream,
                  builder: (context, snapshot) {
                    if (_companyId == null) {
                      return _buildMessageUI(
                        icon: Icons.business_outlined,
                        title: 'No estás en una empresa',
                        subtitle: 'Contacta a tu administrador para que te añada a una.',
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _buildMessageUI(
                        icon: Icons.error_outline,
                        title: 'Error al cargar',
                        subtitle: 'No se pudieron cargar los proveedores. Inténtalo de nuevo.',
                      );
                    }

                    final suppliers = snapshot.data ?? [];

                    if (suppliers.isEmpty) {
                      return _buildMessageUI(
                        icon: Icons.store_mall_directory_outlined,
                        title: 'No hay proveedores',
                        subtitle: 'El administrador de tu empresa aún no ha añadido proveedores.',
                      );
                    }

                    // ✅ CAMBIO: Usamos GridView.builder en lugar de ListView.builder
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 tarjetas por fila
                        crossAxisSpacing: 16, // Espacio horizontal
                        mainAxisSpacing: 16,  // Espacio vertical
                        childAspectRatio: 0.85, // Relación de aspecto (más alto que ancho)
                      ),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        // Usamos el nuevo widget de tarjeta
                        return _buildSupplierGridCard(context, supplier);
                      },
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

  // ✅ NUEVO WIDGET: Tarjeta de proveedor para la cuadrícula
  Widget _buildSupplierGridCard(BuildContext context, Supplier supplier) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias, // Para que la imagen respete los bordes redondeados
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateOrderScreen(supplier: supplier),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contenedor de la imagen
            Expanded(
              flex: 3, // La imagen ocupa más espacio
              child: Container(
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: supplier.imageUrl != null && supplier.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: supplier.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.business,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                )
                    : const Icon(
                  Icons.business,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            // Contenedor del texto
            Expanded(
              flex: 2, // El texto ocupa menos espacio
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildMessageUI({required IconData icon, required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppTheme.secondaryTextColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
