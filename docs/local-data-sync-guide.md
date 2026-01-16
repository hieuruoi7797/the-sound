# Local Data Sync Guide

This guide explains how the app handles syncing local cached data (Recents and Favorites) with updated database information, particularly when avatar image URLs change.

## Problem

When the database is updated with new avatar image URLs, the local cached data in SharedPreferences still contains the old URLs. This causes the "My Tune" → "Recents" tab to show outdated images even after the database has been updated.

## Solution

The app now automatically syncs local data with database updates and provides manual sync options.

## How It Works

### Automatic Sync

1. **Database Fetch**: When `HomeViewModel` fetches data from Firebase
2. **Data Comparison**: The system compares local cached sounds with database sounds by `sound_id`
3. **URL Update**: If avatar URLs have changed, the local cache is updated
4. **State Refresh**: The UI is updated with the new data

### Manual Sync

- **Debug Mode**: A sync button (🔄) appears in the My Tune screen (debug mode only)
- **Cache Refresh**: A refresh button appears in the Home screen (debug mode only)

## Implementation Details

### Files Modified

1. **`lib/features/my_tune/my_tune_view_model.dart`**
   - Added `syncRecentsWithDatabase()` method
   - Added `syncFavoritesWithDatabase()` method

2. **`lib/features/home/viewmodels/home_view_model.dart`**
   - Added automatic sync when database data is fetched
   - Added manual sync methods

3. **`lib/features/my_tune/my_tune_view.dart`**
   - Added sync button in debug mode

### Key Methods

#### `syncRecentsWithDatabase(List<SoundModel> databaseSounds)`
- Compares local recents with database sounds
- Updates avatar URLs if they've changed
- Saves updated data back to SharedPreferences
- Updates the UI state

#### `syncFavoritesWithDatabase(List<SoundModel> databaseSounds)`
- Same as recents but for favorites
- Ensures favorites also get updated URLs

## Usage

### For Users
- The sync happens automatically when the app fetches new data
- No manual intervention needed in production

### For Developers
- Use the debug sync button to manually trigger sync
- Check console logs for sync activity:
  ```
  🔄 Updating recent sound 11: old_url -> new_url
  ✅ Recents synced with database
  ```

## Benefits

1. **Automatic Updates**: Local cache stays in sync with database
2. **Image Consistency**: Avatar images always show the latest versions
3. **Performance**: Only updates when URLs actually change
4. **Debug Support**: Manual sync options for testing

## Environment Considerations

- **Production**: Automatic sync only
- **Development**: Automatic sync + manual sync buttons
- **Cache Management**: Works with existing cache invalidation system

## Testing

1. Update avatar URLs in the dev database
2. Run the dev flavor: `flutter run --flavor dev -t lib/main_dev.dart`
3. Check that Recents tab shows updated images
4. Use debug sync button to manually trigger sync if needed

## Troubleshooting

### Images Still Show Old URLs
1. Check if database actually has new URLs
2. Use debug sync button to force sync
3. Clear app cache completely if needed

### Sync Not Working
1. Check console logs for error messages
2. Verify `sound_id` matching between local and database
3. Ensure SharedPreferences has write permissions

## Future Enhancements

- Add version tracking for more efficient sync
- Implement background sync
- Add sync status indicators in UI
- Batch sync operations for better performance