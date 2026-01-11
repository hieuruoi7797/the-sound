# App Flavors Guide

This project supports multiple flavors (environments) to separate development and production configurations.

## Available Flavors

### Production
- **Database**: `https://my-tune-1ac48-default-rtdb.asia-southeast1.firebasedatabase.app`
- **App Name**: MyTune
- **Bundle ID**: `com.splat.mytune`

### Dev
- **Database**: `https://my-tune-dev.asia-southeast1.firebasedatabase.app`
- **App Name**: MyTune Dev
- **Bundle ID**: `com.splat.mytune` (same as production)

## Key Features

- **Same App Identity**: Both flavors use the same bundle ID and Firebase configuration
- **Dynamic Database URLs**: The database URL is determined at runtime based on the selected flavor
- **Environment Indicator**: Dev flavor shows an orange "DEV" badge in debug mode
- **Shared Permissions**: Both flavors have the same Firebase permissions and authentication

## Running the App

### Using Flutter Commands

#### Development Flavor
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

#### Production Flavor
```bash
flutter run --flavor production -t lib/main_production.dart
```

### Using Build Script
```bash
# Run dev flavor
./scripts/build_flavors.sh run-dev

# Run production flavor
./scripts/build_flavors.sh run-prod
```

### Using VS Code
Use the launch configurations in `.vscode/launch.json`:
- **MyTune (Dev)** - Runs the dev flavor
- **MyTune (Production)** - Runs the production flavor

## Building the App

### Android

#### Development APK
```bash
flutter build apk --flavor dev -t lib/main_dev.dart
# or
./scripts/build_flavors.sh android-dev
```

#### Production APK
```bash
flutter build apk --flavor production -t lib/main_production.dart
# or
./scripts/build_flavors.sh android-prod
```

### iOS

#### Development Build
```bash
flutter build ios --flavor dev -t lib/main_dev.dart
# or
./scripts/build_flavors.sh ios-dev
```

#### Production Build
```bash
flutter build ios --flavor production -t lib/main_production.dart
# or
./scripts/build_flavors.sh ios-prod
```

## Configuration Files

### Android
- `android/app/build.gradle` - Contains flavor definitions
- `android/app/google-services.json` - Shared Firebase config (supports both package names)

### iOS
- `ios/Flutter/Production.xcconfig` - Production configuration
- `ios/Flutter/Dev.xcconfig` - Dev configuration
- `ios/Runner/GoogleService-Info.plist` - Shared Firebase config

### Flutter
- `lib/core/config/app_config.dart` - Environment configuration
- `lib/main_production.dart` - Production entry point
- `lib/main_dev.dart` - Dev entry point

## Environment Indicator

In debug mode, the dev flavor shows an orange "DEV" badge in the top-right corner to help identify which environment you're running.

## Database Configuration

The app automatically connects to the appropriate Firebase Realtime Database based on the selected flavor:
- **Production**: Uses the main production database
- **Dev**: Uses the development database for testing

The database URL is configured in `AppConfig` and used by `RealtimeDatabaseService`.

## Firebase Configuration

Both flavors share the same Firebase project configuration but connect to different database instances:
- The `google-services.json` file includes both package names (`com.splat.mytune` and `com.splat.mytune.dev`)
- The `GoogleService-Info.plist` file works for both iOS bundle identifiers
- Database URLs are handled programmatically in the Flutter code

## Notes

- Both flavors use the same bundle ID and Firebase configuration
- Only the database URL changes between environments
- Environment-specific settings are managed through `AppConfig`
- The dev database URL points to your development Firebase Realtime Database instance
- **Note**: Since both flavors have the same bundle ID, only one can be installed at a time on the same device