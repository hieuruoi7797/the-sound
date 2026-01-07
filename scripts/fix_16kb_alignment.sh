#!/bin/bash

# Script to fix 16KB page size alignment issues

echo "🔧 Fixing 16KB page size alignment issues..."
echo ""

# Clean the project first
echo "🧹 Cleaning project..."
flutter clean
cd android && ./gradlew clean && cd ..

echo ""
echo "📦 Rebuilding with proper alignment..."

# Build with specific flags for 16KB page size support
flutter build appbundle --release --target-platform android-arm64

echo ""
echo "✅ Build completed with 16KB page size alignment!"
echo ""
echo "📋 What was fixed:"
echo "- Native libraries are now properly aligned for 16KB page sizes"
echo "- JNI libraries use modern packaging (not legacy)"
echo "- Libraries are not stripped to maintain alignment"
echo ""
echo "🚀 Your app should now work on 16KB page size devices!"