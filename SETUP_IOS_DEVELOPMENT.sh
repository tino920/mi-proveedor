#!/bin/bash

# 🍎 CONFIGURACIÓN AUTOMÁTICA iOS DEVELOPMENT
# Por MobilePro - Solo para testing, NO App Store

echo "🚀 CONFIGURANDO iOS PARA DESARROLLO..."

PROJECT_PATH="C:\Users\danie\Downloads\tu_proveedor"
BUNDLE_ID="com.miproveedor.app"

# ✅ PASO 1: Verificar Flutter
echo "📱 Verificando Flutter para iOS..."
flutter doctor

# ✅ PASO 2: Actualizar dependencias iOS
echo "📦 Actualizando dependencias..."
cd "$PROJECT_PATH"
flutter clean
flutter pub get

# ✅ PASO 3: Configurar CocoaPods (iOS dependencies)
echo "🧩 Configurando CocoaPods..."
cd ios
pod install --repo-update

# ✅ PASO 4: Actualizar bundle ID en proyecto
echo "🎯 Configurando Bundle ID: $BUNDLE_ID"

# Crear archivo de configuración del Bundle ID
cat > Runner/Config-Development.xcconfig << EOF
#include "Generated.xcconfig"

// 📱 Configuración para desarrollo iOS
PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID
DEVELOPMENT_TEAM = 
PRODUCT_NAME = MiProveedor
MARKETING_VERSION = 1.0.0
CURRENT_PROJECT_VERSION = 1

// 🔧 Configuración de signing para desarrollo
CODE_SIGN_STYLE = Automatic
DEVELOPMENT_TEAM = 
PROVISIONING_PROFILE_SPECIFIER = 

// 🎯 Target mínimo iOS
IPHONEOS_DEPLOYMENT_TARGET = 12.0
EOF

echo "✅ Configuración iOS completada!"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "1. 📥 Descargar GoogleService-Info.plist de Firebase"
echo "2. 📁 Colocarlo en ios/Runner/"
echo "3. 🔧 Abrir ios/Runner.xcworkspace en Xcode"
echo "4. ⚙️ Configurar Team de desarrollo en Xcode"
echo "5. ▶️ Ejecutar: flutter run -d ios"
echo ""
echo "🔗 Bundle ID configurado: $BUNDLE_ID"
echo "📱 Ya puedes hacer build para dispositivos iOS!"
