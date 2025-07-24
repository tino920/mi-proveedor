import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../generated/l10n/app_localizations.dart';

/// 🌍 PROVIDER DE LOCALIZACIÓN PROFESIONAL
/// Maneja traducciones, detección automática de idioma del dispositivo
/// y persistencia de la selección del usuario - 5 IDIOMAS COMPLETOS
class LocalizationProvider extends ChangeNotifier {
  
  // 🔧 ESTADO INTERNO
  Locale _currentLocale = const Locale('es', 'ES');
  AppLocalizations? _localizations;
  bool _isInitialized = false;
  
  // ✨ GETTERS
  Locale get currentLocale => _currentLocale;
  AppLocalizations? get localizations => _localizations;
  bool get isInitialized => _isInitialized;
  String get currentLanguageCode => _currentLocale.languageCode;
  
  // 🌍 IDIOMAS SOPORTADOS COMPLETOS
  static const List<Locale> supportedLocales = [
    Locale('es', 'ES'), // 🇪🇸 Español
    Locale('en', 'US'), // 🇺🇸 Inglés  
    Locale('ca', 'ES'), // 🏴󠁥󠁳󠁣󠁴󠁿 Catalán
    Locale('fr', 'FR'), // 🇫🇷 Francés
    Locale('it', 'IT'), // 🇮🇹 Italiano
  ];
  
  // 📱 INFORMACIÓN COMPLETA DE IDIOMAS
  static const Map<String, Map<String, String>> languageInfo = {
    'es': {
      'name': '🇪🇸 Español',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
    'en': {
      'name': '🇺🇸 English', 
      'nativeName': 'English',
      'flag': '🇺🇸',
    },
    'ca': {
      'name': '🏴󠁥󠁳󠁣󠁴󠁿 Català',
      'nativeName': 'Català', 
      'flag': '🏴󠁥󠁳󠁣󠁴󠁿',
    },
    'fr': {
      'name': '🇫🇷 Français',
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },
    'it': {
      'name': '🇮🇹 Italiano',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
    },
  };
  
  // 🚀 INICIALIZACIÓN COMPLETA
  Future<void> initialize() async {
    try {
      debugPrint('[LOCALIZATION] 🌍 Inicializando sistema de localización 5 idiomas...');
      
      // 1. Cargar idioma guardado o detectar del dispositivo
      await _loadSavedLanguageOrDetectDevice();
      
      // 2. Marcar como inicializado
      _isInitialized = true;
      
      debugPrint('[LOCALIZATION] ✅ Sistema 5 idiomas inicializado correctamente');
      debugPrint('[LOCALIZATION] 📍 Idioma actual: ${_currentLocale.languageCode}');
      
      notifyListeners();
      
    } catch (e) {
      debugPrint('[LOCALIZATION] ❌ Error inicializando: $e');
      // Fallback a español en caso de error
      _currentLocale = const Locale('es', 'ES');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  // 📲 DETECTAR IDIOMA DEL DISPOSITIVO O CARGAR GUARDADO
  Future<void> _loadSavedLanguageOrDetectDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('selected_language');
      
      if (savedLanguage != null && _isLanguageSupported(savedLanguage)) {
        // Usar idioma guardado
        debugPrint('[LOCALIZATION] 💾 Idioma guardado encontrado: $savedLanguage');
        await setLocale(Locale(savedLanguage));
      } else {
        // Detectar idioma del dispositivo
        debugPrint('[LOCALIZATION] 🔍 Detectando idioma del dispositivo...');
        await _detectAndSetDeviceLanguage();
      }
    } catch (e) {
      debugPrint('[LOCALIZATION] ⚠️ Error cargando configuración: $e');
      // Fallback a español
      _currentLocale = const Locale('es', 'ES');
    }
  }
  
  // 🔍 DETECTAR IDIOMA DEL DISPOSITIVO
  Future<void> _detectAndSetDeviceLanguage() async {
    try {
      // Obtener idioma del dispositivo
      final deviceLocales = WidgetsBinding.instance.platformDispatcher.locales;
      debugPrint('[LOCALIZATION] 📱 Idiomas del dispositivo: $deviceLocales');
      
      // Buscar el primer idioma soportado
      for (final deviceLocale in deviceLocales) {
        if (_isLanguageSupported(deviceLocale.languageCode)) {
          debugPrint('[LOCALIZATION] ✅ Idioma del dispositivo soportado: ${deviceLocale.languageCode}');
          await setLocale(Locale(deviceLocale.languageCode));
          return;
        }
      }
      
      // Si no se encuentra ningún idioma soportado, usar español por defecto
      debugPrint('[LOCALIZATION] 🔄 Ningún idioma del dispositivo soportado, usando español por defecto');
      _currentLocale = const Locale('es', 'ES');
      
    } catch (e) {
      debugPrint('[LOCALIZATION] ❌ Error detectando idioma del dispositivo: $e');
      _currentLocale = const Locale('es', 'ES');
    }
  }
  
  // 🌐 CAMBIAR IDIOMA
  Future<void> setLocale(Locale locale) async {
    try {
      // ARREGLADO: Solo verifica el código de idioma, no la combinación exacta
      if (!_isLanguageSupported(locale.languageCode)) {
        debugPrint('[LOCALIZATION] ⚠️ Idioma no soportado: $locale');
        return;
      }
      
      debugPrint('[LOCALIZATION] 🔄 Cambiando idioma a: ${locale.languageCode}');
      debugPrint('[LOCALIZATION] 📍 Idioma anterior: ${_currentLocale.languageCode}');
      
      _currentLocale = locale;
      
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', locale.languageCode);
      
      debugPrint('[LOCALIZATION] ✅ Idioma cambiado y guardado exitosamente');
      debugPrint('[LOCALIZATION] 🎯 Idioma actual: ${_currentLocale.languageCode}');
      
      // CRÍTICO: Notificar a todos los listeners
      notifyListeners();
      
    } catch (e) {
      debugPrint('[LOCALIZATION] ❌ Error cambiando idioma: $e');
    }
  }
  
  // 🔧 UTILIDADES
  bool _isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }
  
  bool _isLocaleSupported(Locale locale) {
    return supportedLocales.contains(locale);
  }
  
  // 📊 INFORMACIÓN DEL IDIOMA ACTUAL
  String get currentLanguageName {
    final info = languageInfo[currentLanguageCode];
    return info?['name'] ?? '🇪🇸 Español';
  }
  
  String get currentLanguageNativeName {
    final info = languageInfo[currentLanguageCode];
    return info?['nativeName'] ?? 'Español';
  }
  
  String get currentLanguageFlag {
    final info = languageInfo[currentLanguageCode];
    return info?['flag'] ?? '🇪🇸';
  }
  
  // 📋 LISTA DE IDIOMAS DISPONIBLES COMPLETA
  List<Map<String, String>> get availableLanguages {
    return supportedLocales.map((locale) {
      final code = locale.languageCode;
      final info = languageInfo[code] ?? {};
      return {
        'code': code,
        'name': info['name'] ?? code.toUpperCase(),
        'nativeName': info['nativeName'] ?? code.toUpperCase(),
        'flag': info['flag'] ?? '🌍',
      };
    }).toList();
  }
  
  // 🔄 RESETEAR A DETECCIÓN AUTOMÁTICA
  Future<void> resetToDeviceLanguage() async {
    try {
      debugPrint('[LOCALIZATION] 🔄 Reseteando a idioma del dispositivo...');
      
      // Eliminar idioma guardado
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_language');
      
      // Re-detectar idioma del dispositivo
      await _detectAndSetDeviceLanguage();
      
      debugPrint('[LOCALIZATION] ✅ Reset completado');
      
    } catch (e) {
      debugPrint('[LOCALIZATION] ❌ Error en reset: $e');
    }
  }
  
  // 📈 ESTADÍSTICAS Y DEBUG
  Map<String, dynamic> get debugInfo => {
    'currentLocale': _currentLocale.toString(),
    'currentLanguageCode': currentLanguageCode,
    'isInitialized': _isInitialized,
    'supportedLocales': supportedLocales.map((l) => l.toString()).toList(),
    'currentLanguageName': currentLanguageName,
    'totalSupportedLanguages': supportedLocales.length,
  };
}

/// 🎯 EXTENSION PARA ACCESO RÁPIDO A TRADUCCIONES
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations == null) {
      throw Exception('❌ AppLocalizations no encontrado. ¿Olvidaste configurar localizationsDelegates?');
    }
    return localizations;
  }
  
  // Método de respaldo que devuelve la clave si no se encuentra la traducción
  String tr(String key, [String? fallback]) {
    try {
      return l10n.toString(); // Esto debería reemplazarse con el acceso real a las traducciones
    } catch (e) {
      return fallback ?? key;
    }
  }
}
