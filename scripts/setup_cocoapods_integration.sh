#!/bin/bash

# Script para configurar CocoaPods integration automáticamente
echo "🔧 Configurando CocoaPods integration en Xcode project..."

# Navegar al directorio iOS
cd ios

# Verificar que los archivos existen
if [ ! -f "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig" ]; then
    echo "❌ Error: CocoaPods files not found. Run 'pod install' first."
    exit 1
fi

echo "✅ CocoaPods files found. Configuring project..."

# Backup original
cp Runner.xcodeproj/project.pbxproj Runner.xcodeproj/project.pbxproj.backup

echo "🔧 Updating project configuration to use CocoaPods settings..."

# Método alternativo: Asegurar que los archivos .xcconfig incluyan CocoaPods
echo "🔍 Verificando Flutter/.xcconfig files..."

# Verificar que nuestros includes están presentes
if grep -q "Pods/Target Support Files" Flutter/Debug.xcconfig; then
    echo "✅ Debug.xcconfig already includes CocoaPods"
else
    echo "🔧 Adding CocoaPods include to Debug.xcconfig"
    echo '#include "../Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' >> Flutter/Debug.xcconfig
fi

if grep -q "Pods/Target Support Files" Flutter/Release.xcconfig; then
    echo "✅ Release.xcconfig already includes CocoaPods"
else
    echo "🔧 Adding CocoaPods include to Release.xcconfig"
    echo '#include "../Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' >> Flutter/Release.xcconfig
fi

# Método adicional: Configurar directamente las variables de build en project.pbxproj
echo "🔧 Ensuring Xcode project uses CocoaPods build settings..."

# Añadir $(inherited) a key build settings si no está presente
python3 << 'EOF'
import re

# Read project file
with open('Runner.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Ensure LIBRARY_SEARCH_PATHS includes $(inherited)
if 'LIBRARY_SEARCH_PATHS' not in content:
    # Add LIBRARY_SEARCH_PATHS to all configurations
    pattern = r'(buildSettings = \{[^}]*)(PRODUCT_BUNDLE_IDENTIFIER[^;]*;)'
    replacement = r'\1LIBRARY_SEARCH_PATHS = (\n\t\t\t\t\t"$(inherited)",\n\t\t\t\t);\n\t\t\t\t\2'
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

# Ensure FRAMEWORK_SEARCH_PATHS includes $(inherited)  
if 'FRAMEWORK_SEARCH_PATHS' not in content:
    pattern = r'(buildSettings = \{[^}]*)(PRODUCT_BUNDLE_IDENTIFIER[^;]*;)'
    replacement = r'\1FRAMEWORK_SEARCH_PATHS = (\n\t\t\t\t\t"$(inherited)",\n\t\t\t\t);\n\t\t\t\t\2'
    content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

# Write back
with open('Runner.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Project configuration updated")
EOF

echo "✅ CocoaPods integration configured successfully"
echo "🔍 Verifying configuration..."

# Verificar archivos críticos
echo "📁 Checking critical files:"
ls -la "Pods/Target Support Files/Pods-Runner/" || echo "⚠️ Pods configs not found"
echo "📄 Debug.xcconfig content:"
cat Flutter/Debug.xcconfig
echo "📄 Release.xcconfig content:"  
cat Flutter/Release.xcconfig

echo "🎯 CocoaPods integration setup complete"
