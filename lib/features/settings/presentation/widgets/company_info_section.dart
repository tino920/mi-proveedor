import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';
import 'package:flutter/services.dart';



class CompanyInfoSection extends StatefulWidget {
  final Map<String, dynamic>? companyData;
  final String companyCode;

  const CompanyInfoSection({
    super.key,
    required this.companyData,
    required this.companyCode,
  });

  @override
  State<CompanyInfoSection> createState() => _CompanyInfoSectionState();
}

class _CompanyInfoSectionState extends State<CompanyInfoSection> {
  // Controladores para editar empresa
  final _companyNameController = TextEditingController();
  final _companyAddressController = TextEditingController();
  final _companyPhoneController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyAddressController.dispose();
    _companyPhoneController.dispose();
    super.dispose();
  }

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
                const Icon(Icons.business, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Información de la Empresa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editCompanyInfo(),
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Editar información',
                ),
              ],
            ),
          ),
          
          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  'Nombre',
                  widget.companyData?['name'] ?? 'No configurado',
                  Icons.store,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Código',
                  widget.companyCode,
                  Icons.qr_code,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Dirección',
                  widget.companyData?['address'] ?? 'No configurada',
                  Icons.location_on,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Teléfono',
                  widget.companyData?['phone'] ?? 'No configurado',
                  Icons.phone,
                ),
                const SizedBox(height: 16),

                // Botón para compartir código de empresa
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _shareCompanyCode(),
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir Código de Empresa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 📋 WIDGET PARA MOSTRAR INFORMACIÓN
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppGradients.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'No configurado',
                style: TextStyle(
                  fontSize: 14,
                  color: value.isNotEmpty ? AppTheme.textColor : AppTheme.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✏️ EDITAR INFORMACIÓN DE EMPRESA
  void _editCompanyInfo() {
    _companyNameController.text = widget.companyData?['name'] ?? '';
    _companyAddressController.text = widget.companyData?['address'] ?? '';
    _companyPhoneController.text = widget.companyData?['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Editar Información de Empresa'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la empresa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyAddressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyPhoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _saveCompanyInfo(),
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

  // 💾 GUARDAR INFORMACIÓN DE EMPRESA
  Future<void> _saveCompanyInfo() async {
    // Validaciones básicas
    if (_companyNameController.text.trim().isEmpty) {
      _showErrorSnackBar('El nombre de la empresa es obligatorio');
      return;
    }

    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId != null) {
        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .update({
          'name': _companyNameController.text.trim(),
          'address': _companyAddressController.text.trim(),
          'phone': _companyPhoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Actualizar datos locales
        await authProvider.refreshUserData();

        if (mounted) {
          Navigator.pop(context); // Cerrar loading
          Navigator.pop(context); // Cerrar dialog
          _showSuccessSnackBar('✅ Información actualizada correctamente');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar loading
        _showErrorSnackBar('❌ Error al actualizar: $e');
      }
    }
  }

  // 📤 COMPARTIR CÓDIGO DE EMPRESA
  void _shareCompanyCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Código de Empresa'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.companyCode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comparte este código con tus empleados para que puedan registrarse en la app.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'El empleado debe:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Descargar MiProveedor'),
                Text('2. Seleccionar "Empleado"'),
                Text('3. Introducir este código'),
                Text('4. Completar registro'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _copyCodeToClipboard();
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar Código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 📋 COPIAR CÓDIGO AL PORTAPAPELES
  void _copyCodeToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.companyCode));
    _showSuccessSnackBar('📋 Código copiado al portapapeles');
  }

  // 📱 UTILIDADES PARA SNACKBARS
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
