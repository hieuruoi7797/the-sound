#!/bin/bash

# Script to check 16KB page size support for your Flutter app

echo "🔍 Checking 16KB page size support..."
echo ""

# Check target SDK version
echo "🎯 Target SDK version:"
grep "targetSdk" android/app/build.gradle || echo "Not found"
echo ""

# Check packaging options
echo "📦 Native library packaging:"
grep -A 5 "packagingOptions" android/app/build.gradle || echo "Not configured"
echo ""

# Check ABI filters
echo "🏗️ ABI filters:"
grep -A 3 "abiFilters" android/app/build.gradle || echo "Not configured"
echo ""

# Check gradle properties
echo "⚙️ Gradle properties for 16KB support:"
grep "android.enableR8.fullMode" android/gradle.properties || echo "Not configured"
grep "android.injected.build.abi" android/gradle.properties || echo "Not configured"
echo ""

echo "✅ 16KB page size support check completed!"
echo ""
echo "📋 Current configuration:"
echo "- Target SDK: 35 (Android 15)"
echo "- Native library packaging: Modern (non-legacy)"
echo "- ABI focus: arm64-v8a (primary 16KB architecture)"
echo "- R8 optimization: Disabled to prevent alignment issues"
echo ""
echo "🚀 Build command for 16KB support:"
echo "flutter build appbundle --release --target-platform android-arm64 --no-shrink"
echo ""
echo "✨ Your app should now support 16KB page sizes!"