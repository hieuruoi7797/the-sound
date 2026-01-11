# Dev Database Setup Guide

This guide helps you set up the development Firebase Realtime Database for the dev flavor.

## Prerequisites

- Firebase project with Realtime Database enabled
- Firebase CLI installed (`npm install -g firebase-tools`)
- Admin access to your Firebase project

## Step 1: Create Dev Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (`my-tune-1ac48`)
3. Navigate to **Realtime Database**
4. Click **Create Database** (if you need a second database)
5. Choose location: **asia-southeast1**
6. Set database URL to: `https://my-tune-dev.asia-southeast1.firebasedatabase.app`

## Step 2: Set Security Rules

Set the following security rules for your dev database to allow read/write access during development:

```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**⚠️ Warning**: These rules allow public access. Only use for development!

For production-like security in dev, use:
```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

## Step 3: Import Data

### Option A: Using Firebase Console
1. Go to your dev database in Firebase Console
2. Click the **⋮** menu → **Import JSON**
3. Upload `my-tune-1ac48-default-rtdb-export-2-updated.json`

### Option B: Using Firebase CLI
```bash
# Login to Firebase
firebase login

# Set your project
firebase use my-tune-1ac48

# Import data to dev database
#firebase database:set / my-tune-1ac48-default-rtdb-export-2-updated.json --instance my-tune-dev
```

## Step 4: Verify Setup

1. Run the dev flavor:
   ```bash
   flutter run --flavor dev -t lib/main_dev.dart
   ```

2. Check the console logs for:
   ```
   [HomeViewModel] Using database URL: https://my-tune-dev.asia-southeast1.firebasedatabase.app
   [HomeViewModel] Environment: dev
   ```

3. Verify data loads without permission errors

## Step 5: Test Data Access

The app should now:
- Connect to the dev database
- Load sound data successfully
- Show the orange "DEV" badge in debug mode
- Display all sounds and categories

## Troubleshooting

### Permission Denied Error
- Check security rules are set correctly
- Verify database URL is accessible
- Ensure data was imported successfully

### No Data Found
- Confirm JSON import completed
- Check database structure matches expected format
- Verify `system_sounds` node exists

### Wrong Database URL
- Check `AppConfig.databaseUrl` in logs
- Verify dev flavor is running (look for "DEV" badge)
- Confirm database URL in Firebase Console

## Database Structure

Your dev database should have this structure:
```
my-tune-dev/
├── frequencies/
│   ├── frequency_id_1/
│   ├── frequency_id_2/
│   └── ...
└── system_sounds/
    ├── sound_id_11/
    ├── sound_id_12/
    └── ...
```

## Security Considerations

- **Development**: Use open rules for easy testing
- **Staging**: Use authentication-based rules
- **Production**: Use strict, role-based rules

Remember to tighten security rules before deploying to production!