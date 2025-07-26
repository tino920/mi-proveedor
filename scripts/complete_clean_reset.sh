#!/bin/bash

# MobilePro - RESET COMPLETO COCOAPODS + FIREBASE
# Basado en análisis correcto del usuario - Clean slate approach
echo "🔥 RESET COMPLETO: Flutter + CocoaPods + Firebase"
echo "================================================="

echo "📂 Working directory: $(pwd)"
echo "🎯 Strategy: Complete clean slate regeneration"

# 1. FLUTTER CLEAN COMPLETO
echo ""
echo "🧹 1. FLUTTER CLEAN COMPLETO..."
cd ..
flutter clean
echo "✅ Flutter clean completed"

# 2. ELIMINAR PODS COMPLETAMENTE
echo ""
echo "🗑️ 2. ELIMINANDO PODS CORRUPTOS..."
cd ios
rm -rf Pods
rm -f Podfile.lock
rm -rf .symlinks
rm -rf Runner.xcworkspace
echo "✅ CocoaPods cache eliminado completamente"

# 3. FLUTTER PUB GET LIMPIO
echo ""
echo "📦 3. FLUTTER PUB GET LIMPIO..."
cd ..
flutter pub get
echo "✅ Flutter dependencies regeneradas"

# 4. VERIFICAR GOOGLESERVICE-INFO.PLIST
echo ""
echo "🔍 4. VERIFICANDO FIREBASE CONFIGURATION..."
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "✅ GoogleService-Info.plist encontrado"
    # Verificar que no esté vacío
    if [ -s "ios/Runner/GoogleService-Info.plist" ]; then
        echo "✅ GoogleService-Info.plist tiene contenido"
    else
        echo "⚠️ ADVERTENCIA: GoogleService-Info.plist está vacío"
    fi
else
    echo "⚠️ ADVERTENCIA: GoogleService-Info.plist NO encontrado"
    echo "🔥 Para Firebase funcional, añádelo a ios/Runner/"
fi

# 5. COCOAPODS INSTALL CLEAN
echo ""
echo "🍎 5. COCOAPODS INSTALL CLEAN + REPO UPDATE..."
cd ios

# Verificar versión CocoaPods
echo "🔍 CocoaPods version:"
pod --version

# Install limpio con repo update
echo "🔄 Ejecutando pod install --repo-update..."
pod install --repo-update --clean-install

echo ""
echo "🔍 6. VERIFICACIÓN POST-INSTALACIÓN..."

# Verificar que los archivos críticos existen
if [ -d "Pods/Target Support Files/Pods-Runner" ]; then
    echo "✅ Pods-Runner configuración generada"
else
    echo "❌ ERROR: Pods-Runner configuración NO generada"
fi

# Verificar Firebase targets específicos
FIREBASE_TARGETS=("FirebaseAnalytics" "GoogleAppMeasurement" "FirebaseCore")
for target in "${FIREBASE_TARGETS[@]}"; do
    target_dir="Pods/Target Support Files/${target}"
    if [ -d "$target_dir" ]; then
        echo "✅ $target: Target Support Files generados"
        # Verificar .xcfilelist files
        if ls "$target_dir"/*.xcfilelist >/dev/null 2>&1; then
            echo "✅ $target: .xcfilelist files presentes"
        else
            echo "⚠️ $target: .xcfilelist files faltantes"
        fi
    else
        echo "❌ $target: Target Support Files NO generados"
    fi
done

# Verificar workspace
if [ -f "Runner.xcworkspace/contents.xcworkspacedata" ]; then
    echo "✅ Xcode workspace regenerado correctamente"
else
    echo "❌ ERROR: Xcode workspace NO regenerado"
fi

echo ""
echo "✅ RESET COMPLETO TERMINADO"
echo "🎯 Firebase .xcfilelist files deberían estar regenerados"
echo "🚀 Proyecto listo para build limpio"

# Mostrar estructura para verificación
echo ""
echo "📁 ESTRUCTURA PODS REGENERADA:"
ls -la Pods/Target\ Support\ Files/ | head -10
