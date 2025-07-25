@echo off
echo 🔧 MobilePro - FIX CACHE CORRUPTION COMPLETO
echo ====================================

echo.
echo 🧹 LIMPIANDO FLUTTER CACHE...
call flutter clean

echo.
echo 🧹 LIMPIANDO PODS CACHE...
cd ios
if exist "Pods" rmdir /s /q "Pods"
if exist "Podfile.lock" del "Podfile.lock"
if exist ".symlinks" rmdir /s /q ".symlinks"
if exist "Runner.xcworkspace" rmdir /s /q "Runner.xcworkspace"
cd ..

echo.
echo 🧹 LIMPIANDO FLUTTER BUILD CACHE...
if exist "build" rmdir /s /q "build"
if exist ".dart_tool" rmdir /s /q ".dart_tool"

echo.
echo 📦 REGENERANDO DEPENDENCIES...
call flutter pub get

echo.
echo 🍎 REINSTALANDO PODS LIMPIO...
cd ios
call pod install --repo-update --clean-install
cd ..

echo.
echo ✅ CACHE CORRUPTION FIXED
echo 🚀 LISTO PARA NUEVO BUILD
echo.
pause
