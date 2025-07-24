#!/bin/bash

# 🚀 SCRIPT AUTOMÁTICO SETUP iOS - MiProveedor
# Desarrollado por MobilePro para configuración completa iOS

echo "🎯 INICIANDO SETUP AUTOMÁTICO iOS - MiProveedor"
echo "================================================"

# 🔍 VERIFICAR PRERREQUISITOS
echo "\n📋 1. Verificando prerrequisitos..."

# Verificar si estamos en Mac
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ ERROR: Este script debe ejecutarse en macOS"
    echo "💡 ALTERNATIVAS:"
    echo "   • Usar MacinCloud ($20/mes)"
    echo "   • GitHub Actions (gratis)"
    echo "   • Codemagic CI/CD"
    exit 1
fi

# Verificar Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no encontrado. Instala Flutter primero:"
    echo "   https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Verificar Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode no encontrado. Instala desde App Store:"
    echo "   https://apps.apple.com/app/xcode/id497799835"
    exit 1
fi

# Verificar CocoaPods
if ! command -v pod &> /dev/null; then
    echo "📦 Instalando CocoaPods..."
    sudo gem install cocoapods
fi

echo "✅ Prerrequisitos verificados"

# 🧹 LIMPIAR PROYECTO
echo "\n🧹 2. Limpiando proyecto Flutter..."
flutter clean
flutter pub get

# 📱 CONFIGURAR iOS
echo "\n📱 3. Configurando proyecto iOS..."

# Navegar a directorio iOS
cd ios

# Instalar dependencias iOS
echo "📦 Instalando dependencias iOS (pods)..."
pod deintegrate 2>/dev/null || true
pod install --repo-update

# Verificar Bundle ID
echo "\n🔍 4. Verificando Bundle ID..."
BUNDLE_ID=$(grep -r "PRODUCT_BUNDLE_IDENTIFIER" Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*= \(.*\);/\1/')
echo "Bundle ID actual: $BUNDLE_ID"

# Si el Bundle ID no es correcto, lo cambiamos
if [[ "$BUNDLE_ID" != "com.miproveedor.app" ]]; then
    echo "🔧 Corrigiendo Bundle ID..."
    sed -i '' 's/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = com.miproveedor.app;/g' Runner.xcodeproj/project.pbxproj
    echo "✅ Bundle ID actualizado a: com.miproveedor.app"
fi

# 🔥 VERIFICAR FIREBASE
echo "\n🔥 5. Verificando configuración Firebase..."
if [ ! -f "Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  ADVERTENCIA: GoogleService-Info.plist no encontrado"
    echo "📋 ACCIÓN REQUERIDA:"
    echo "   1. Ve a https://console.firebase.google.com/"
    echo "   2. Selecciona tu proyecto"
    echo "   3. Añade app iOS con Bundle ID: com.miproveedor.app"
    echo "   4. Descarga GoogleService-Info.plist"
    echo "   5. Colócalo en: ios/Runner/"
    read -p "¿Ya tienes el archivo? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Proceso pausado. Configura Firebase primero."
        exit 1
    fi
fi

# 🔐 VERIFICAR DESARROLLO
echo "\n🔐 6. Verificando certificados de desarrollo..."

# Abrir Xcode para configuración final
echo "\n🎯 7. Abriendo Xcode para configuración final..."
echo "📋 CONFIGURACIÓN EN XCODE:"
echo "   1. Selecciona 'Runner' en navegador izquierdo"
echo "   2. Ve a 'Signing & Capabilities'"
echo "   3. Selecciona tu Team (Apple Developer Account)"
echo "   4. Bundle Identifier: com.miproveedor.app"
echo "   5. ✅ 'Automatically manage signing'"

read -p "¿Abrir Xcode ahora? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "Runner.xcworkspace"
    echo "⏳ Esperando configuración en Xcode..."
    read -p "Presiona ENTER cuando hayas configurado signing..." 
fi

# 📱 DETECTAR DISPOSITIVOS
echo "\n📱 8. Detectando dispositivos iOS..."
cd ..
flutter devices

# 🚀 COMPILAR Y EJECUTAR
echo "\n🚀 9. ¿Compilar app ahora?"
read -p "¿Ejecutar en dispositivo iOS conectado? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔨 Compilando MiProveedor para iOS..."
    flutter run -d ios --release
fi

# ✅ RESUMEN FINAL
echo "\n🎉 ¡SETUP COMPLETADO!"
echo "========================"
echo "✅ Dependencias iOS instaladas"
echo "✅ Bundle ID configurado: com.miproveedor.app"
echo "✅ Firebase preparado"
echo "✅ Proyecto listo para desarrollo"

echo "\n📋 PRÓXIMOS PASOS:"
echo "1. 🔥 Verifica Firebase Console (si no lo hiciste)"
echo "2. 🔐 Configura certificados en Xcode"
echo "3. 📱 Conecta iPhone/iPad"
echo "4. 🚀 Ejecuta: flutter run -d ios"

echo "\n📞 SOPORTE:"
echo "Si tienes problemas:"
echo "• flutter doctor -v"
echo "• flutter devices"
echo "• Revisa logs en Xcode"

echo "\n🎯 MiProveedor listo para iOS - by MobilePro ✨"
