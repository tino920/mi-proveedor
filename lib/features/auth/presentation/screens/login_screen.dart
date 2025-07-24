import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../shared/widgets/gradient_widgets.dart' hide GradientContainer;
import 'package:mi_proveedor/generated/l10n/app_localizations.dart';


/// Modos de autenticación disponibles en la pantalla
enum AuthMode {
  login,
  registerCompany,
  registerEmployee
}

/// Pantalla principal de autenticación para MiProveedor
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // === CONTROLLERS ===
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyCodeController = TextEditingController();
  final _positionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // === ESTADO LOCAL ===
  bool _isLoading = false;
  bool _obscurePassword = true;
  AuthMode _authMode = AuthMode.login;
  String? _lastCompanyCode;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _companyNameController.dispose();
    _companyCodeController.dispose();
    _positionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // === MÉTODOS DE AUTENTICACIÓN ===

  /// Maneja todas las operaciones de autenticación según el modo actual
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      late AuthResult result;

      switch (_authMode) {
        case AuthMode.login:
          result = await authProvider.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          break;

        case AuthMode.registerCompany:
          result = await authProvider.registerCompany(
            companyName: _companyNameController.text.trim(),
            adminEmail: _emailController.text.trim(),
            adminPassword: _passwordController.text,
            adminName: _nameController.text.trim(),
            address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
            phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          );

          if (result.success) {
            _lastCompanyCode = result.data?['companyCode'];
            _showCompanyRegistrationSuccess();
            return;
          }
          break;

        case AuthMode.registerEmployee:
          result = await authProvider.registerEmployee(
            companyCode: _companyCodeController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            position: _positionController.text.trim().isNotEmpty ? _positionController.text.trim() : null,
          );

          if (result.success) {
            _showEmployeeRegistrationSuccess();
            return;
          }
          break;
      }

      // 🚀 MANEJO DE ERRORES MEJORADO
      if (!result.success && mounted) {
        _showSmartErrorMessage(result.error ?? 'Error desconocido');
      }

    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Maneja el reset de contraseña
  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar('Ingresa tu email para recuperar la contraseña');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<RestauAuthProvider>(context, listen: false);
      final result = await authProvider.resetPassword(email: email);

      if (mounted) {
        if (result.success) {
          _showSuccessSnackBar('Se ha enviado un enlace de recuperación a tu email');
        } else {
          _showErrorSnackBar(result.error ?? 'Error al enviar email de recuperación');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // === 🚀 NUEVOS MÉTODOS DE ERROR MEJORADOS ===

  /// Muestra mensaje de error inteligente según el tipo
  void _showSmartErrorMessage(String error) {
    if (!mounted) return;

    // 🔍 DETECTAR TIPO DE ERROR Y MOSTRAR DIÁLOGO ESPECÍFICO
    if (error.contains('Email no registrado') || error.contains('user-not-found')) {
      _showEmailNotFoundDialog();
    } else if (error.contains('Contraseña incorrecta') || error.contains('wrong-password')) {
      _showWrongPasswordDialog();
    } else if (error.contains('Email inválido') || error.contains('invalid-email')) {
      _showInvalidEmailDialog();
    } else {
      _showErrorSnackBar(error);
    }
  }

  /// Diálogo para email no encontrado
  void _showEmailNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.person_search, color: Colors.orange, size: 48),
        title: const Text('Email no registrado', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Este email no existe en nuestro sistema.\n\n'
          '• Verifica que esté escrito correctamente\n'
          '• ¿Es tu primera vez? Regístrate como empleado\n'
          '• ¿Olvidaste el email? Contacta a tu administrador',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _authMode = AuthMode.registerEmployee);
              _clearFields();
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Registrarse'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para contraseña incorrecta
  void _showWrongPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.lock_open, color: Colors.red.shade600, size: 48),
        title: const Text('Contraseña incorrecta', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'La contraseña no es correcta.\n\n'
          '• Verifica mayúsculas y minúsculas\n'
          '• ¿Olvidaste tu contraseña? Usa la opción de recuperar\n'
          '• Contacta a tu administrador si el problema persiste',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _handlePasswordReset();
            },
            icon: const Icon(Icons.email),
            label: const Text('Recuperar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para email inválido
  void _showInvalidEmailDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.email_outlined, color: AppTheme.errorColor, size: 48),
        title: const Text('Email inválido', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'El formato del email no es correcto.\n\n'
          'Ejemplo válido: usuario@empresa.com\n\n'
          'Verifica que no tenga espacios ni caracteres especiales.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // === MÉTODOS DE UI ORIGINALES ===

  void _showCompanyRegistrationSuccess() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
        title: const Text('¡Empresa Registrada!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tu empresa ha sido registrada exitosamente.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GradientContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Código de Empresa:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SelectableText(_lastCompanyCode ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Comparte este código con tus empleados para que puedan registrarse.', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          GradientButton(
            text: 'Continuar',
            onPressed: () {
              Navigator.of(context).pop();
              _switchToLogin();
            },
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  void _showEmployeeRegistrationSuccess() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.check_circle, color: AppTheme.successColor, size: 64),
        title: const Text('¡Registro Exitoso!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tu cuenta ha sido creada correctamente. Ya puedes iniciar sesión.', textAlign: TextAlign.center),
        actions: [
          GradientButton(
            text: 'Iniciar Sesión',
            onPressed: () {
              Navigator.of(context).pop();
              _switchToLogin();
            },
            icon: Icons.login,
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _switchToLogin() {
    setState(() => _authMode = AuthMode.login);
    _clearFields();
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _companyNameController.clear();
    _companyCodeController.clear();
    _positionController.clear();
    _addressController.clear();
    _phoneController.clear();
  }

  // === MÉTODOS DE CONSTRUCCIÓN DE UI ===

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildLoginCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.restaurant_menu, size: 64, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context).appName, // "MiProveedor" / "MySupplier" / etc.
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),        const SizedBox(height: 8),
        Text(_getSubtitle(), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(12)),
              child: Text(_getModeTitle(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 24),
            
            ..._buildFormFields(),
            const SizedBox(height: 24),
            _buildMainButton(),
            if (_authMode == AuthMode.login) ...[
              const SizedBox(height: 12),
              _buildForgotPasswordButton(),
            ],
            const SizedBox(height: 16),
            ..._buildModeLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return GradientButton(
      text: _isLoading ? 'Cargando...' : _getButtonText(),
      onPressed: _isLoading ? null : () => _handleAuth(),
      icon: _isLoading ? null : Icons.login,
      isLoading: _isLoading,
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _isLoading ? null : () => _handlePasswordReset(),
      child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppTheme.primaryColor)),
    );
  }

  String _getModeTitle() {
    switch (_authMode) {
      case AuthMode.login: return 'Iniciar Sesión';
      case AuthMode.registerCompany: return 'Registrar Empresa';
      case AuthMode.registerEmployee: return 'Registrar Empleado';
    }
  }

  String _getSubtitle() {
    switch (_authMode) {
      case AuthMode.login: return 'Inicia sesión para gestionar tus pedidos';
      case AuthMode.registerCompany: return 'Registra tu restaurante y comienza a optimizar tus pedidos';
      case AuthMode.registerEmployee: return 'Únete a tu equipo con el código de empresa';
    }
  }

  String _getButtonText() {
    switch (_authMode) {
      case AuthMode.login: return 'Iniciar Sesión';
      case AuthMode.registerCompany: return 'Registrar Empresa';
      case AuthMode.registerEmployee: return 'Registrarse';
    }
  }

  List<Widget> _buildFormFields() {
    final fields = <Widget>[];

    // Campo de email (siempre presente)
    fields.addAll([
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email *',
          hintText: 'correo@ejemplo.com',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.email, color: Colors.white, size: 20),
          ),
          filled: true,
          fillColor: AppTheme.backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Por favor ingresa tu email';
          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
            return 'Por favor ingresa un email válido';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
    ]);

    // Campo de contraseña (siempre presente)
    fields.addAll([
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Contraseña *',
          hintText: '••••••••',
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(gradient: AppGradients.primaryGradient, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.lock, color: Colors.white, size: 20),
          ),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: AppTheme.primaryColor),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          helperText: _authMode != AuthMode.login ? 'Mínimo 8 caracteres' : null,
          filled: true,
          fillColor: AppTheme.backgroundColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Por favor ingresa tu contraseña';
          if (_authMode != AuthMode.login && value.length < 8) {
            return 'La contraseña debe tener al menos 8 caracteres';
          }
          return null;
        },
      ),
    ]);

    return fields;
  }

  List<Widget> _buildModeLinks() {
    if (_authMode == AuthMode.login) {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿No tienes cuenta? '),
            TextButton(
              onPressed: () {
                setState(() => _authMode = AuthMode.registerEmployee);
                _clearFields();
              },
              child: Text('Registrarse', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            setState(() => _authMode = AuthMode.registerCompany);
            _clearFields();
          },
          child: Text('Registrar nueva empresa', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
        ),
      ];
    } else {
      return [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿Ya tienes cuenta? '),
            TextButton(
              onPressed: () {
                setState(() => _authMode = AuthMode.login);
                _clearFields();
              },
              child: Text('Iniciar sesión', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ];
    }
  }
}
