import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart';

/// 🏢 PANTALLA DE POLÍTICAS DE EMPRESA
class CompanyPoliciesScreen extends StatefulWidget {
  const CompanyPoliciesScreen({super.key});

  @override
  State<CompanyPoliciesScreen> createState() => _CompanyPoliciesScreenState();
}

class _CompanyPoliciesScreenState extends State<CompanyPoliciesScreen> {
  // 🔒 POLÍTICAS DE PEDIDOS
  bool _requireApprovalOver200 = true;
  bool _workingHoursOnly = false;
  bool _blockSundays = true;
  double _maxOrderAmount = 500.0;

  // 👥 POLÍTICAS DE EMPLEADOS
  bool _monthlyLimitsEnabled = true;
  double _monthlyLimitPerEmployee = 1500.0;
  bool _restrictCategories = false;

  // 🏭 POLÍTICAS OPERATIVAS
  bool _autoBackup = true;
  bool _requirePasswordChange = false;

  // ⚙️ ESTADO
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              // 🎨 Header con gradiente
              _buildHeader(),

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
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                      : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 10),

                      // 🔒 Políticas de Pedidos
                      _buildOrderPoliciesSection(),

                      const SizedBox(height: 20),

                      // 👥 Políticas de Empleados
                      _buildEmployeePoliciesSection(),

                      const SizedBox(height: 20),

                      // 🏭 Políticas Operativas
                      _buildOperationalPoliciesSection(),

                      const SizedBox(height: 30),

                      // 💾 Botón guardar
                      if (_hasChanges) _buildSaveButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📱 HEADER DE LA PANTALLA
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rule,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Políticas de Empresa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔒 SECCIÓN DE POLÍTICAS DE PEDIDOS
  Widget _buildOrderPoliciesSection() {
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
            child: const Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Políticas de Pedidos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPolicySwitch(
                  'Aprobación obligatoria >€200',
                  'Pedidos superiores a €200 requieren aprobación',
                  Icons.check_circle,
                  _requireApprovalOver200,
                      (value) => setState(() {
                    _requireApprovalOver200 = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                _buildPolicySwitch(
                  'Solo en horario laboral',
                  'Permitir pedidos únicamente de 9:00 a 18:00',
                  Icons.schedule,
                  _workingHoursOnly,
                      (value) => setState(() {
                    _workingHoursOnly = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                _buildPolicySwitch(
                  'Bloquear domingos',
                  'No permitir crear pedidos los domingos',
                  Icons.block,
                  _blockSundays,
                      (value) => setState(() {
                    _blockSundays = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                // Límite máximo por pedido
                _buildAmountSetting(
                  'Límite máximo por pedido',
                  'Cantidad máxima permitida por pedido individual',
                  Icons.euro,
                  _maxOrderAmount,
                      (value) => setState(() {
                    _maxOrderAmount = value;
                    _hasChanges = true;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 👥 SECCIÓN DE POLÍTICAS DE EMPLEADOS
  Widget _buildEmployeePoliciesSection() {
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
            child: const Row(
              children: [
                Icon(Icons.people, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Políticas de Empleados',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPolicySwitch(
                  'Límites mensuales activos',
                  'Aplicar límites mensuales por empleado',
                  Icons.calendar_month,
                  _monthlyLimitsEnabled,
                      (value) => setState(() {
                    _monthlyLimitsEnabled = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                // Límite mensual por empleado
                _buildAmountSetting(
                  'Límite mensual por empleado',
                  'Cantidad máxima que puede pedir cada empleado al mes',
                  Icons.person,
                  _monthlyLimitPerEmployee,
                      (value) => setState(() {
                    _monthlyLimitPerEmployee = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                _buildPolicySwitch(
                  'Restringir categorías',
                  'Algunos empleados solo pueden pedir ciertas categorías',
                  Icons.category,
                  _restrictCategories,
                      (value) => setState(() {
                    _restrictCategories = value;
                    _hasChanges = true;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏭 SECCIÓN DE POLÍTICAS OPERATIVAS
  Widget _buildOperationalPoliciesSection() {
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
            child: const Row(
              children: [
                Icon(Icons.settings, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Políticas Operativas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Contenido de la sección
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPolicySwitch(
                  'Backup automático',
                  'Realizar respaldo de datos automáticamente',
                  Icons.backup,
                  _autoBackup,
                      (value) => setState(() {
                    _autoBackup = value;
                    _hasChanges = true;
                  }),
                ),
                const Divider(height: 24),

                _buildPolicySwitch(
                  'Cambio obligatorio de contraseña',
                  'Empleados deben cambiar contraseña cada 90 días',
                  Icons.security,
                  _requirePasswordChange,
                      (value) => setState(() {
                    _requirePasswordChange = value;
                    _hasChanges = true;
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 WIDGET PARA SWITCH DE POLÍTICA
  Widget _buildPolicySwitch(
      String title,
      String subtitle,
      IconData icon,
      bool value,
      Function(bool) onChanged,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: value
                ? AppGradients.primaryGradient
                : LinearGradient(
              colors: [
                AppTheme.secondaryTextColor.withOpacity(0.3),
                AppTheme.secondaryTextColor.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: value ? Colors.white : AppTheme.secondaryTextColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value ? AppTheme.textColor : AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
          inactiveThumbColor: AppTheme.secondaryTextColor,
          inactiveTrackColor: AppTheme.secondaryTextColor.withOpacity(0.2),
        ),
      ],
    );
  }

  // 💰 WIDGET PARA CONFIGURAR CANTIDADES
  Widget _buildAmountSetting(
      String title,
      String subtitle,
      IconData icon,
      double value,
      Function(double) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  activeColor: AppTheme.primaryColor,
                  inactiveColor: AppTheme.primaryColor.withOpacity(0.3),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '€${value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 💾 BOTÓN GUARDAR CAMBIOS
  Widget _buildSaveButton() {
    return GradientButton(
      text: 'Guardar Políticas',
      icon: Icons.save,
      onPressed: _savePolicies,
      isLoading: _isLoading,
    );
  }

  // 📥 CARGAR POLÍTICAS DESDE FIREBASE
  Future<void> _loadPolicies() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final policies = data['policies'] as Map<String, dynamic>? ?? {};

          setState(() {
            // Políticas de pedidos
            _requireApprovalOver200 = policies['requireApprovalOver200'] ?? true;
            _workingHoursOnly = policies['workingHoursOnly'] ?? false;
            _blockSundays = policies['blockSundays'] ?? true;
            _maxOrderAmount = (policies['maxOrderAmount'] ?? 500.0).toDouble();

            // Políticas de empleados
            _monthlyLimitsEnabled = policies['monthlyLimitsEnabled'] ?? true;
            _monthlyLimitPerEmployee = (policies['monthlyLimitPerEmployee'] ?? 1500.0).toDouble();
            _restrictCategories = policies['restrictCategories'] ?? false;

            // Políticas operativas
            _autoBackup = policies['autoBackup'] ?? true;
            _requirePasswordChange = policies['requirePasswordChange'] ?? false;
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error cargando políticas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 💾 GUARDAR POLÍTICAS EN FIREBASE
  Future<void> _savePolicies() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<RestauAuthProvider>();
      final companyId = authProvider.companyId;

      if (companyId != null) {
        final policies = {
          // Políticas de pedidos
          'requireApprovalOver200': _requireApprovalOver200,
          'workingHoursOnly': _workingHoursOnly,
          'blockSundays': _blockSundays,
          'maxOrderAmount': _maxOrderAmount,

          // Políticas de empleados
          'monthlyLimitsEnabled': _monthlyLimitsEnabled,
          'monthlyLimitPerEmployee': _monthlyLimitPerEmployee,
          'restrictCategories': _restrictCategories,

          // Políticas operativas
          'autoBackup': _autoBackup,
          'requirePasswordChange': _requirePasswordChange,

          // Metadatos
          'lastUpdated': FieldValue.serverTimestamp(),
          'updatedBy': authProvider.user?.uid,
        };

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(companyId)
            .update({
          'policies': policies,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() => _hasChanges = false);
        _showSuccessSnackBar('✅ Políticas guardadas correctamente');

        // Regresar a la pantalla anterior después de guardar
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      _showErrorSnackBar('❌ Error guardando políticas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 📱 UTILIDADES PARA SNACKBARS
  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
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
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
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