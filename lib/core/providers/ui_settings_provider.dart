import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// 🎨 PROVIDER PARA CONFIGURACIONES DE UI/UX
/// Maneja tema, tamaño de texto, idioma y autenticación biométrica
class UISettingsProvider extends ChangeNotifier {
  // 🎨 CONFIGURACIONES DE TEMA
  ThemeMode _themeMode = ThemeMode.light;
  bool _useSystemTheme = false;

  // 📝 CONFIGURACIONES DE TEXTO
  double _textScale = 1.0;
  String _fontFamily = 'default';

  // 🌍 CONFIGURACIONES DE IDIOMA
  String _selectedLanguage = 'es';
  Locale _currentLocale = const Locale('es', 'ES');

  // 🔐 CONFIGURACIONES BIOMÉTRICAS
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];
  final LocalAuthentication _localAuth = LocalAuthentication();

  // 🔧 ESTADO
  bool _isLoading = false;
  String? _error;

  // ✨ GETTERS
  ThemeMode get themeMode => _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  double get textScale => _textScale;
  String get fontFamily => _fontFamily;
  
  String get selectedLanguage => _selectedLanguage;
  Locale get currentLocale => _currentLocale;
  
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get biometricStatusText {
    if (!_isBiometricAvailable) {
      return 'No disponible en este dispositivo';
    }

    if (_availableBiometrics.isEmpty) {
      return 'No hay datos biométricos configurados';
    }

    final types = <String>[];
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      types.add('Huella dactilar');
    }
    if (_availableBiometrics.contains(BiometricType.face)) {
      types.add('Reconocimiento facial');
    }
    if (_availableBiometrics.contains(BiometricType.iris)) {
      types.add('Reconocimiento de iris');
    }

    final statusText = _isBiometricEnabled ? 'Activado' : 'Desactivado';
    return '$statusText (${types.join(', ')})';
  }

  // 🏗️ INICIALIZACIÓN
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadThemeSettings(),
        _loadTextSettings(),
        _loadLanguageSettings(),
        _initializeBiometrics(),
      ]);
    } catch (e) {
      _error = 'Error inicializando configuraciones: $e';
      debugPrint('UISettingsProvider initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🎨 GESTIÓN DE TEMA
  Future<void> _loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final themeIndex = prefs.getInt('theme_mode') ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      
      _useSystemTheme = prefs.getBool('use_system_theme') ?? false;
      
      // Si usa tema del sistema, ajustar según el sistema
      if (_useSystemTheme) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      debugPrint('Error loading theme settings: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      _useSystemTheme = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('theme_mode', mode.index);
      await prefs.setBool('use_system_theme', false);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error cambiando tema: $e';
      notifyListeners();
    }
  }

  Future<void> setSystemTheme(bool useSystem) async {
    try {
      _useSystemTheme = useSystem;
      
      if (useSystem) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _themeMode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_system_theme', useSystem);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error configurando tema del sistema: $e';
      notifyListeners();
    }
  }

  String get themeDisplayName {
    if (_useSystemTheme) return 'Automático';
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }

  // 📝 GESTIÓN DE TAMAÑO DE TEXTO
  Future<void> _loadTextSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _textScale = prefs.getDouble('text_scale') ?? 1.0;
      _fontFamily = prefs.getString('font_family') ?? 'default';
    } catch (e) {
      debugPrint('Error loading text settings: $e');
    }
  }

  Future<void> setTextScale(double scale) async {
    try {
      _textScale = scale.clamp(0.8, 1.4); // Limitar entre 80% y 140%
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('text_scale', _textScale);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error cambiando tamaño de texto: $e';
      notifyListeners();
    }
  }

  Future<void> setFontFamily(String fontFamily) async {
    try {
      _fontFamily = fontFamily;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('font_family', fontFamily);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error cambiando fuente: $e';
      notifyListeners();
    }
  }

  String get textSizeDisplayName {
    if (_textScale <= 0.9) return 'Pequeño';
    if (_textScale >= 1.1) return 'Grande';
    return 'Normal';
  }

  // 🌍 GESTIÓN DE IDIOMA
  Future<void> _loadLanguageSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _selectedLanguage = prefs.getString('selected_language') ?? 'es';
      
      // Actualizar locale
      switch (_selectedLanguage) {
        case 'es':
          _currentLocale = const Locale('es', 'ES');
          break;
        case 'en':
          _currentLocale = const Locale('en', 'US');
          break;
        case 'ca':
          _currentLocale = const Locale('ca', 'ES');
          break;
        default:
          _currentLocale = const Locale('es', 'ES');
      }
    } catch (e) {
      debugPrint('Error loading language settings: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      _selectedLanguage = languageCode;
      
      // Actualizar locale
      switch (languageCode) {
        case 'es':
          _currentLocale = const Locale('es', 'ES');
          break;
        case 'en':
          _currentLocale = const Locale('en', 'US');
          break;
        case 'ca':
          _currentLocale = const Locale('ca', 'ES');
          break;
        default:
          _currentLocale = const Locale('es', 'ES');
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', languageCode);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error cambiando idioma: $e';
      notifyListeners();
    }
  }

  String get languageDisplayName {
    switch (_selectedLanguage) {
      case 'es':
        return '🇪🇸 Español';
      case 'en':
        return '🇺🇸 English';
      case 'ca':
        return '🏴󠁥󠁳󠁣󠁴󠁿 Català';
      default:
        return '🇪🇸 Español';
    }
  }

  List<Map<String, String>> get availableLanguages => [
    {'code': 'es', 'name': '🇪🇸 Español', 'nativeName': 'Español'},
    {'code': 'en', 'name': '🇺🇸 English', 'nativeName': 'English'},
    {'code': 'ca', 'name': '🏴󠁥󠁳󠁣󠁴󠁿 Català', 'nativeName': 'Català'},
  ];

  Future<void> _initializeBiometrics() async {
    debugPrint('[BIOMETRIC DEBUG] 1. Inicializando biometría...');
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      debugPrint('[BIOMETRIC DEBUG] 2. ¿Dispositivo compatible?: $_isBiometricAvailable');

      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        debugPrint('[BIOMETRIC DEBUG] 3. Tipos de biometría encontrados: $_availableBiometrics');
      }

      final prefs = await SharedPreferences.getInstance();
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      debugPrint('[BIOMETRIC DEBUG] 4. ¿Estaba habilitado previamente?: $_isBiometricEnabled');

      if (_isBiometricEnabled && !_isBiometricAvailable) {
        _isBiometricEnabled = false;
        await prefs.setBool('biometric_enabled', false);
        debugPrint('[BIOMETRIC DEBUG] AVISO: Se deshabilitó porque ya no está disponible.');
      }
    } catch (e) {
      debugPrint('[BIOMETRIC DEBUG] !!! ERROR en inicialización: $e');
      _isBiometricAvailable = false;
      _isBiometricEnabled = false;
    }
  }

  Future<bool> toggleBiometric() async {
    debugPrint('[BIOMETRIC DEBUG] 5. Intentando cambiar el estado. Habilitado actualmente: $_isBiometricEnabled');
    if (!_isBiometricAvailable) {
      _error = 'La biometría no está disponible en este dispositivo.';
      debugPrint('[BIOMETRIC DEBUG] Fallo: La biometría no está disponible.');
      notifyListeners();
      return false;
    }

    if (_isBiometricEnabled) {
      // Deshabilitar
      _isBiometricEnabled = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', false);
      debugPrint('[BIOMETRIC DEBUG] 6. Biometría DESHABILITADA con éxito.');
      notifyListeners();
      return true;
    } else {
      // Habilitar
      debugPrint('[BIOMETRIC DEBUG] 6. Se necesita autenticar para HABILITAR...');
      final isAuthenticated = await authenticateWithBiometric(
          reason: 'Habilitar autenticación biométrica para futuras sesiones'
      );
      debugPrint('[BIOMETRIC DEBUG] 8. Resultado de la autenticación: $isAuthenticated');

      if (isAuthenticated) {
        _isBiometricEnabled = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_enabled', true);
        debugPrint('[BIOMETRIC DEBUG] 9. Biometría HABILITADA con éxito.');
        notifyListeners();
        return true;
      } else {
        debugPrint('[BIOMETRIC DEBUG] 9. Falló la habilitación porque la autenticación fue denegada.');
        return false;
      }
    }
  }

  Future<bool> authenticateWithBiometric({String reason = 'Autenticar para continuar'}) async {
    debugPrint('[BIOMETRIC DEBUG] 7. Llamando a local_auth.authenticate con razón: "$reason"');
    try {
      if (!_isBiometricAvailable) {
        debugPrint('[BIOMETRIC DEBUG] Fallo en authenticate: Biometría no disponible.');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true, // Solo permite huella/rostro, no PIN
          stickyAuth: true,
        ),
      );
      debugPrint('[BIOMETRIC DEBUG] El paquete local_auth devolvió: $isAuthenticated');
      return isAuthenticated;
    } on PlatformException catch (e) {
      debugPrint('[BIOMETRIC DEBUG] !!! ERROR de Plataforma en authenticate: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'NotEnrolled':
          _error = 'No tienes huellas/rostro configurados en tu dispositivo.';
          break;
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          _error = 'Biometría bloqueada por demasiados intentos.';
          break;
        default:
          _error = 'Error inesperado de biometría.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[BIOMETRIC DEBUG] !!! ERROR GENERAL en authenticate: $e');
      _error = 'Ocurrió un error desconocido.';
      notifyListeners();
      return false;
    }
  }

  // 🔄 UTILIDADES
  Future<void> resetToDefaults() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      
      // Reset tema
      _themeMode = ThemeMode.light;
      _useSystemTheme = false;
      await prefs.setInt('theme_mode', 0);
      await prefs.setBool('use_system_theme', false);
      
      // Reset texto
      _textScale = 1.0;
      _fontFamily = 'default';
      await prefs.setDouble('text_scale', 1.0);
      await prefs.setString('font_family', 'default');
      
      // Reset idioma
      _selectedLanguage = 'es';
      _currentLocale = const Locale('es', 'ES');
      await prefs.setString('selected_language', 'es');
      
      // Reset biométrica
      _isBiometricEnabled = false;
      await prefs.setBool('biometric_enabled', false);
      
      _error = null;
    } catch (e) {
      _error = 'Error reseteando configuraciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 📊 INFORMACIÓN DEL SISTEMA
  Map<String, dynamic> get systemInfo => {
    'theme_mode': _themeMode.toString(),
    'use_system_theme': _useSystemTheme,
    'text_scale': _textScale,
    'font_family': _fontFamily,
    'language': _selectedLanguage,
    'biometric_available': _isBiometricAvailable,
    'biometric_enabled': _isBiometricEnabled,
    'available_biometrics': _availableBiometrics.map((e) => e.toString()).toList(),
  };
}
