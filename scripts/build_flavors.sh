#!/bin/bash

# Build script for different flavors

case "$1" in
  "android-dev")
    echo "Building Android Dev flavor..."
    flutter build apk --flavor dev -t lib/main_dev.dart
    ;;
  "android-prod")
    echo "Building Android Production flavor..."
    flutter build apk --flavor production -t lib/main_production.dart
    ;;
  "ios-dev")
    echo "Building iOS Dev flavor..."
    flutter build ios --flavor dev -t lib/main_dev.dart
    ;;
  "ios-prod")
    echo "Building iOS Production flavor..."
    flutter build ios --flavor production -t lib/main_production.dart
    ;;
  "run-dev")
    echo "Running Dev flavor..."
    flutter run --flavor dev -t lib/main_dev.dart
    ;;
  "run-prod")
    echo "Running Production flavor..."
    flutter run --flavor production -t lib/main_production.dart
    ;;
  *)
    echo "Usage: $0 {android-dev|android-prod|ios-dev|ios-prod|run-dev|run-prod}"
    echo ""
    echo "Examples:"
    echo "  $0 run-dev          # Run dev flavor"
    echo "  $0 run-prod         # Run production flavor"
    echo "  $0 android-dev      # Build Android dev APK"
    echo "  $0 android-prod     # Build Android production APK"
    echo "  $0 ios-dev          # Build iOS dev"
    echo "  $0 ios-prod         # Build iOS production"
    exit 1
    ;;
esac