# Firebase Analytics Tracking Plan
## MyTune - White Noise & Ambient Sound App

**Version:** 1.0 (Phase 1 - MVP)  
**Last Updated:** 2024-01-15  
**Reviewed & Updated:** 2024-01-15 (Aligned with codebase - Phase 1 MVP)  
**Owner:** Development Team

**⚠️ Phase 1 MVP Focus**: This tracking plan focuses on core analytics and essential metrics only. Advanced features (Environment Scan, Timer, Fade Settings) will be tracked in Phase 2.

---

## 📊 Table of Contents

1. [Business Goals & KPIs](#business-goals--kpis)
2. [Screen Tracking](#screen-tracking)
3. [Event Tracking](#event-tracking)
4. [User Properties](#user-properties)
5. [Funnels & Conversions](#funnels--conversions)
6. [Mode & Tag Reference](#mode--tag-reference)
7. [Naming Conventions](#naming-conventions)
8. [Implementation Guidelines](#implementation-guidelines)

---

## 🎯 Business Goals & KPIs

### Primary Goals (Phase 1 - MVP)
1. **User Engagement**: Measure daily active users, session duration, and audio play completion rates
2. **Content Discovery**: Track which sounds/modes are most popular and effective
3. **Retention**: Monitor user return rate and favorite usage
4. **Basic User Satisfaction**: Track favorites usage and basic feature interactions

**Note**: Advanced feature tracking (Environment Scan, Timer, Fade Settings) will be implemented in Phase 2.

### Key Performance Indicators (KPIs) - Phase 1
- **Daily Active Users (DAU)**: Automatic tracking
- **Average Session Duration**: Automatic tracking
- **Audio Play Completion Rate**: Track when users finish playing audio
- **Favorite Adoption Rate**: % of users who favorite sounds
- **Mode Distribution**: Which daily modes are most used
- **Sound Discovery Source**: Home, Mode, Top Picks, My Tune (Recents/Favorites)

---

## 📱 Screen Tracking

### Manual Screen Tracking (Method 2)

**Important**: Firebase Analytics does NOT automatically track screen views in Flutter apps. You need to manually log `screen_view` events when users navigate to screens.

**Why Manual?**: Flutter uses a single `Activity`/`UIViewController` for the entire app, so Firebase cannot automatically detect screen changes like in native Android/iOS apps.

---

### Implementation Guide

#### Step 1: Create Analytics Helper

Create a helper class/service to centralize analytics calls:

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Log screen view manually
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
        parameters: parameters,
      );
      if (kDebugMode) {
        debugPrint('📊 Screen view: $screenName');
      }
    } catch (e) {
      debugPrint('❌ Analytics error (screen_view): $e');
      // Don't crash app on analytics errors
    }
  }
}
```

#### Step 2: Log Screen Views in Each Screen

Add `logScreenView` in `initState()` or use `addPostFrameCallback` to ensure screen is fully built:

**Example 1: StatefulWidget with initState**

```dart
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Log screen view when screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(
        screenName: 'home',
        screenClass: 'HomeScreen',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... screen content
  }
}
```

**Example 2: For Tab Changes (Bottom Navigation)**

```dart
// In NavigatorUI or tab change handler
void _onTabChanged(int newIndex) {
  String screenName = _getScreenName(newIndex);
  AnalyticsService.logScreenView(
    screenName: screenName,
    screenClass: _getScreenClass(newIndex),
  );
}

String _getScreenName(int index) {
  switch (index) {
    case 0: return 'home';
    case 1: return 'my_tune';
    case 2: return 'settings';
    default: return 'unknown';
  }
}
```

**Example 3: For Modal Bottom Sheets (Timer Settings, Fade Settings)**

```dart
// In timer settings modal
showModalBottomSheet(
  context: context,
  builder: (context) {
    // Log screen view for modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(
        screenName: 'timer_settings',
        screenClass: 'TimerSettingView',
        parameters: {
          'is_modal': true,
          'current_timer_seconds': currentTimerSeconds,
        },
      );
    });
    return TimerSettingView();
  },
);

// In fade settings modal
showModalBottomSheet(
  context: context,
  builder: (context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(
        screenName: 'fade_settings',
        screenClass: 'FadeSettingScreen',
        parameters: {
          'is_modal': true,
          'fade_type': fadeType, // 'fade_in' or 'fade_out'
          'current_fade_seconds': currentFadeSeconds,
        },
      );
    });
    return FadeSettingScreen();
  },
);
```

**Example 4: For Screens with Parameters**

```dart
// Mode Sounds Screen with mode info
class ModeSoundsScreen extends ConsumerWidget {
  final String title;
  final int tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Log screen view with parameters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.logScreenView(
        screenName: 'mode_sounds',
        screenClass: 'ModeSoundsScreen',
        parameters: {
          'mode_name': _getModeName(tag),
          'mode_tag': tag,
          'sound_count': sounds.length,
        },
      );
    });
    
    // ... screen content
  }
}
```

---

### Screens to Track

| Screen Name | Screen Class | When to Track | Required Parameters | Optional Parameters |
|------------|--------------|---------------|---------------------|---------------------|
| `home` | `HomeScreen` | When home screen is displayed | None | None |
| `my_tune` | `MyTuneView` | When My Tune screen is displayed | None | `active_tab` ("recents" or "favorites"), `favorites_count`, `recents_count` |
| `settings` | `SettingsScreen` | When settings screen is displayed | None | None |
| `sound_player` | `SoundPlayerUI` | When full player screen is expanded | None | `audio_id`, `audio_title` |
| `mode_sounds` | `ModeSoundsScreen` | When mode sounds list is displayed | `mode_name`, `mode_tag` | `sound_count` |
| `environment_scan` | `RecordingView` | When environment scan screen is displayed | None | None |
| `timer_settings` | `TimerSettingView` | When timer settings modal is opened | None | `current_timer_seconds`, `is_modal` |
| `fade_settings` | `FadeSettingScreen` | When fade settings modal is opened | `fade_type` | `current_fade_seconds`, `is_modal` |

**Note**: Screen tracking is included for these advanced features, but event tracking for Environment Scan, Timer, and Fade Settings will be implemented in Phase 2.

---

### Screen View Event Structure

#### Standard Screen View (No Parameters)

```dart
AnalyticsService.logScreenView(
  screenName: 'home',
  screenClass: 'HomeScreen',
);
```

#### Screen View with Parameters

```dart
// Mode Sounds Screen with mode info
AnalyticsService.logScreenView(
  screenName: 'mode_sounds',
  screenClass: 'ModeSoundsScreen',
  parameters: {
    'mode_name': 'easy_sleep',
    'mode_tag': 202,
    'sound_count': 12,
  },
);

// My Tune with active tab
AnalyticsService.logScreenView(
  screenName: 'my_tune',
  screenClass: 'MyTuneView',
  parameters: {
    'active_tab': 'favorites', // or 'recents'
    'favorites_count': 8,
  },
);

// Sound Player with audio info
AnalyticsService.logScreenView(
  screenName: 'sound_player',
  screenClass: 'SoundPlayerUI',
  parameters: {
    'audio_id': '123',
    'audio_title': 'White Noise',
  },
);
```

---

### Best Practices

**DO**:
- ✅ Log screen view in `initState()` with `addPostFrameCallback` to ensure screen is fully built
- ✅ Use consistent `screenName` values (snake_case)
- ✅ Include relevant parameters for context (mode_name, audio_id, etc.)
- ✅ Handle errors gracefully - don't crash app if analytics fails
- ✅ Use helper service for consistency and error handling

**DON'T**:
- ❌ Log screen view in `build()` method directly (can be called multiple times)
- ❌ Log screen view multiple times for same screen visit
- ❌ Include sensitive information in screen names or parameters
- ❌ Log screen view for every widget rebuild

---

### Implementation Checklist

- [ ] Create `AnalyticsService` helper class
- [ ] Add `logScreenView` to `HomeScreen` (initState)
- [ ] Add `logScreenView` to `MyTuneView` (with tab tracking)
- [ ] Add `logScreenView` to `SettingsScreen` (initState)
- [ ] Add `logScreenView` to `SoundPlayerUI` (when expanded)
- [ ] Add `logScreenView` to `ModeSoundsScreen` (with mode parameters)
- [ ] Add `logScreenView` to `RecordingView` (environment scan screen)
- [ ] Add `logScreenView` to timer settings modal
- [ ] Add `logScreenView` to fade settings modal
- [ ] Add `logScreenView` to tab change handler (bottom navigation)
- [ ] Test all screen views in debug mode
- [ ] Verify in Firebase Console DebugView

**Note**: Screen tracking is implemented for all screens including advanced features (environment_scan, timer_settings, fade_settings). Event tracking for these features will be added in Phase 2.

---

## 🎵 Event Tracking (Phase 1 - MVP)

**Phase 1 Focus**: Core analytics and essential metrics only. Advanced features tracking will be added in Phase 2.

### 1. Audio Playback Events (Core)

#### `play_audio`
**Purpose**: Track when user starts playing audio content  
**Trigger**: When audio playback starts (after 1 second to avoid accidental taps)  
**Business Goal**: Measure user engagement with audio content

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `audio_type` | String | Yes | Type of content | "colored_noise", "meditation", "nature" |
| `genre` | String | No | Category/genre | "white_noise", "brown_noise", "pink_noise" |
| `mode` | String | No | Daily mode category | "easy_sleep", "relax", "stress_relief", "deep_work", "energy_boost", "meditate", "body_healing" |
| `source` | String | Yes | Where user started playback | "home_colored_noise", "home_top_picks", "home_daily_mode", "mode_sounds", "top_picks", "my_tune_recent", "my_tune_favorite" |
| `duration_seconds` | Int | No | Total audio duration | 300 |
| `has_timer` | Boolean | No | Whether timer is set (Phase 2) | true, false |
| `timer_duration_seconds` | Int | No | Timer duration if set (Phase 2) | 1800 |
| `fade_in_seconds` | Int | No | Fade in setting (Phase 2) | 5 |
| `fade_out_seconds` | Int | No | Fade out setting (Phase 2) | 10 |

**Example Implementation**:
```dart
await analytics.logEvent(
  name: 'play_audio',
  parameters: {
    'audio_id': sound.soundId.toString(),
    'audio_title': sound.title,
    'audio_type': _getAudioType(sound.tags),
    'genre': _getGenre(sound.tags),
    'mode': _getMode(sound.tags),
    'source': 'home_colored_noise', // or 'home_top_picks', 'mode_sounds', 'my_tune_recent', etc.
    'duration_seconds': sound.duration,
    // Phase 2: Add timer and fade parameters
    // 'has_timer': timerDuration > 0,
    // 'timer_duration_seconds': timerDuration.inSeconds,
    // 'fade_in_seconds': fadeInSeconds,
    // 'fade_out_seconds': fadeOutSeconds,
  },
);
```

**Related Events**: `pause_audio`, `stop_audio`, `complete_audio`

---

#### `pause_audio`
**Purpose**: Track when user pauses audio playback  
**Trigger**: When user taps pause button  
**Business Goal**: Understand user listening patterns and engagement

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `position_seconds` | Int | Yes | Playback position when paused | 150 |
| `total_duration_seconds` | Int | Yes | Total audio duration | 300 |
| `playback_percentage` | Double | Yes | Percentage of audio played | 50.0 |

**Example Implementation**:
```dart
await analytics.logEvent(
  name: 'pause_audio',
  parameters: {
    'audio_id': sound.soundId.toString(),
    'audio_title': sound.title,
    'position_seconds': currentTime.inSeconds,
    'total_duration_seconds': totalDuration.inSeconds,
    'playback_percentage': (currentTime.inSeconds / totalDuration.inSeconds) * 100,
  },
);
```

---

#### `stop_audio`
**Purpose**: Track when user stops audio playback  
**Trigger**: When audio is stopped (not paused)  
**Business Goal**: Measure early exit rate

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `position_seconds` | Int | Yes | Playback position when stopped | 45 |
| `total_duration_seconds` | Int | Yes | Total audio duration | 300 |
| `playback_percentage` | Double | Yes | Percentage of audio played | 15.0 |

---

#### `complete_audio`
**Purpose**: Track when user completes audio playback (90%+ of duration)  
**Trigger**: When playback reaches 90% of duration  
**Business Goal**: Measure completion rate and user satisfaction

**Note**: Timer-related completion tracking will be added in Phase 2.

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `total_duration_seconds` | Int | Yes | Total audio duration | 300 |
| `completed_by` | String | Yes | How completion happened | "duration", "user_action" |

**Note**: 
- `resume_audio` event will be added in Phase 2 for advanced playback analytics.
- Timer-related completion tracking (`has_timer` parameter, `timer_completed` event) will be added in Phase 2.

---

### 2. Content Discovery Events (Core)

#### `tap_sound_card`
**Purpose**: Track when user taps a sound card to play  
**Trigger**: When user taps sound card  
**Business Goal**: Measure content discovery and selection

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `source` | String | Yes | Where card was tapped | "home_colored_noise", "home_top_picks", "home_daily_mode", "mode_sounds", "my_tune_recent", "my_tune_favorite" |

---

#### `view_mode_sounds`
**Purpose**: Track when user views a mode sounds list  
**Trigger**: When ModeSoundsScreen is displayed  
**Business Goal**: Measure mode category interest

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `mode_name` | String | Yes | Name of the mode (snake_case) | "easy_sleep", "relax", "stress_relief", "deep_work", "energy_boost", "meditate", "body_healing", "top_picks" |
| `mode_tag` | Int | Yes | Mode tag identifier | 202, 303, 404, 505, 606, 707, 808, 000, 101 |
| `sound_count` | Int | Yes | Number of sounds in mode | 12 |

---

#### `tap_daily_mode`
**Purpose**: Track when user taps a daily mode card on home  
**Trigger**: When user taps daily mode card  
**Business Goal**: Measure mode interest

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `mode_name` | String | Yes | Name of the mode (snake_case) | "easy_sleep", "relax", "stress_relief", "deep_work", "energy_boost", "meditate", "body_healing" |
| `mode_tag` | Int | Yes | Mode tag identifier | 202, 303, 404, 505, 606, 707, 808 |

**Note**: `view_sound_card` (impression tracking) will be added in Phase 2 for detailed content analytics.

---

### 3. User Interaction Events (Core)

#### `favorite_audio`
**Purpose**: Track when user favorites/unfavorites audio  
**Trigger**: When user taps like/favorite button  
**Business Goal**: Measure content preference and user engagement

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `audio_id` | String | Yes | Unique sound identifier | "123" |
| `audio_title` | String | Yes | Title of the audio | "White Noise" |
| `action` | String | Yes | Favorite action | "add", "remove" |
| `source` | String | Yes | Where action occurred | "sound_player", "my_tune" |
| `total_favorites` | Int | No | Total number of user favorites | 5 |

**Note**: Advanced interaction events (`view_favorites`, `view_recents`, `tap_mini_player`, `collapse_player`) will be added in Phase 2 for detailed user behavior tracking.

---

### 4. Navigation Events (Core)

#### `change_tab`
**Purpose**: Track when user switches bottom navigation tabs  
**Trigger**: When user taps bottom nav item  
**Business Goal**: Measure navigation patterns

**Parameters**:
| Parameter | Type | Required | Description | Example Values |
|-----------|------|----------|-------------|----------------|
| `from_tab` | String | Yes | Previous tab | "home", "my_tune", "settings" |
| `to_tab` | String | Yes | New tab | "home", "my_tune", "settings" |

**Note**: 
- `view_see_all` event will be added in Phase 2 for detailed content exploration tracking.
- Error & Performance events (`audio_load_error`, `scan_permission_denied`) will be added in Phase 2.
- Session & Engagement events (`session_start`) will be added in Phase 2.

---

## 🔮 Phase 2 Events (Future)

The following events will be implemented in Phase 2 for advanced analytics:

### Environment Scan Events
- `tap_environment_scan_banner`
- `start_environment_scan`
- `complete_environment_scan`
- `cancel_environment_scan`
- `view_scan_results`
- `select_scan_scene`
- `play_recommended_sound`
- `scan_again`

### Timer Events
- `open_timer_settings`
- `set_timer`
- `clear_timer`
- `timer_completed`

### Settings Events
- `open_fade_settings`
- `set_fade_in`
- `set_fade_out`
- `tap_rate_app`
- `tap_share_app`
- `view_privacy_policy`
- `view_terms_of_use`

### Advanced Content Discovery
- `view_sound_card` (impression tracking)
- `view_favorites`
- `view_recents`
- `tap_mini_player`
- `collapse_player`
- `resume_audio`
- `view_see_all`

### Error & Performance
- `audio_load_error`
- `scan_permission_denied`

### Session Tracking
- `session_start` (custom session tracking)

---

## 👤 User Properties (Phase 1 - MVP)

User properties are set once per user and persist across sessions. Update when values change.

### Profile Properties (Core)

| Property Name | Type | When to Set | Description | Example Values |
|---------------|------|-------------|-------------|----------------|
| `user_type` | String | On first app open | User classification | "new", "returning", "active" |
| `signup_date` | String | On first app open | Date user first opened app | "2024-01-15" |
| `total_favorites` | Int | When favorites change | Total number of favorites | 12 |
| `total_sounds_played` | Int | Increment on play | Total sounds ever played | 45 |
| `favorite_genre` | String | Update when favorites change | Most favorited genre | "white_noise" |
| `favorite_mode` | String | Update when mode usage changes | Most used daily mode | "easy_sleep" |

**Note**: Advanced user properties (`total_play_time_minutes`, `has_used_scan`, `has_used_timer`, `scan_count`, `preferred_fade_in`, `preferred_fade_out`, behavioral properties) will be added in Phase 2.

**Example Implementation**:
```dart
await analytics.setUserProperty(
  name: 'total_favorites',
  value: favorites.length.toString(),
);

await analytics.setUserProperty(
  name: 'favorite_genre',
  value: _calculateFavoriteGenre(favorites),
);

await analytics.setUserProperty(
  name: 'favorite_mode',
  value: _calculateFavoriteMode(playHistory),
);
```

---

## 🔄 Funnels & Conversions

### Funnel 1: First Audio Play
**Goal**: Measure onboarding success - getting users to play their first audio

1. `first_open` (automatic)
2. `screen_view` with `screen_name = 'home'` (**manual** - log in HomeScreen)
3. `tap_sound_card` OR `tap_daily_mode`
4. `play_audio`

**Success Criteria**: 70%+ of users play audio within first session

---

### Funnel 2: Audio Discovery to Play
**Goal**: Measure content discovery effectiveness

1. `view_mode_sounds` OR `tap_daily_mode`
2. `tap_sound_card`
3. `play_audio`
4. `complete_audio` (optional - long-term engagement)

**Success Criteria**: 40%+ of mode views result in plays, 60%+ of plays complete

**Note**: `view_sound_card` (impression tracking) will be added in Phase 2 for more detailed analytics.

---

### Funnel 3: Favorites Adoption
**Goal**: Measure favorite feature adoption

1. `play_audio`
2. `favorite_audio` with `action = 'add'`

**Success Criteria**: 30%+ of users favorite at least one sound

**Note**: Additional funnels (Environment Scan to Play, Timer Usage) will be added in Phase 2.

---

### Conversion Events (Phase 1 - MVP)

Mark these as conversion events in Firebase Console:
- ✅ `play_audio` - Primary engagement metric
- ✅ `complete_audio` - Content completion
- ✅ `favorite_audio` with `action = 'add'` - User preference

**Phase 2**: Additional conversion events (`set_timer`, `complete_environment_scan`, `share_app`) will be added later.

---

## 📝 Mode & Tag Reference

**Mode/Tag Mapping** (for reference when implementing):
- Tag **202** = "Easy Sleep" (analytics mode: `"easy_sleep"`)
- Tag **303** = "Relax" (analytics mode: `"relax"`) 
- Tag **404** = "Meditate" (analytics mode: `"meditate"`)
- Tag **505** = "Deep Work" (analytics mode: `"deep_work"`)
- Tag **606** = "Energy Boost" (analytics mode: `"energy_boost"`)
- Tag **707** = "Stress Relief" (analytics mode: `"stress_relief"`)
- Tag **808** = "Body Healing" (analytics mode: `"body_healing"`)
- Tag **000** = "Top Picks" (analytics mode: `"top_picks"`)
- Tag **101** = "Colored Noise" (category, not a mode)

**Environment Scan Scene Names** (different from mode names - use exactly as shown in UI):
- `"sleep"` (not "easy_sleep")
- `"relax"`
- `"stress_relief"`
- `"deep_work"`
- `"energy_boost"`
- `"meditate"`
- No "body_healing" in scan scenes

**Source Values** for `source` parameter in events (Phase 1):
- `"home_colored_noise"` - From colored noise cards on home screen
- `"home_top_picks"` - From top picks section on home screen
- `"home_daily_mode"` - From daily mode cards on home screen (when tapped)
- `"mode_sounds"` - From mode sounds list screen
- `"top_picks"` - From top picks full screen ("See all")
- `"my_tune_recent"` - From recents tab in My Tune
- `"my_tune_favorite"` - From favorites tab in My Tune

**Phase 2**: Additional source values (`scan_recommended`, etc.) will be added later.

---

## 📝 Naming Conventions

### Event Names
- **Format**: `snake_case` (lowercase with underscores)
- **Pattern**: `verb_noun` (e.g., `play_audio`, `set_timer`)
- **Examples**:
  - ✅ `play_audio`
  - ✅ `favorite_audio`
  - ✅ `start_environment_scan`
  - ❌ `PlayAudio` (PascalCase)
  - ❌ `play-audio` (kebab-case)
  - ❌ `playAudio` (camelCase)

### Parameter Names
- **Format**: `snake_case` (lowercase with underscores)
- **Examples**:
  - ✅ `audio_id`, `audio_title`, `timer_duration_seconds`
  - ❌ `audioId`, `audio-title`, `audioID`

### User Property Names
- **Format**: `snake_case` (lowercase with underscores)
- **Examples**:
  - ✅ `total_favorites`, `favorite_genre`, `has_used_scan`
  - ❌ `totalFavorites`, `favorite-genre`

### Reserved Event Names (DO NOT USE)
Firebase Analytics reserves these event names. Use alternative names if needed:
- `screen_view` (automatic on native, **manual in Flutter** - use `logScreenView()`)
- `first_open` (automatic)
- `session_start` (automatic)
- `ad_*` (all ad events)
- `app_exception` (use `audio_load_error` instead)
- `app_remove`
- `app_update`
- `in_app_purchase`
- `notification_received`

---

## 🛠 Implementation Guidelines

### 1. Event Logging Best Practices

**DO**:
- ✅ Log events immediately when action occurs
- ✅ Include all required parameters
- ✅ Use consistent parameter types (String, Int, Double, Boolean)
- ✅ Validate parameter values before logging
- ✅ Log events in background thread if needed (non-blocking)

**DON'T**:
- ❌ Log sensitive user information (email, personal data)
- ❌ Log too frequently (e.g., every second during playback)
- ❌ Use different parameter names for same data
- ❌ Log events in tight loops
- ❌ Log events for actions user didn't explicitly take

### 2. Parameter Validation

Always validate parameters before logging:
```dart
// Good
if (audioId != null && audioTitle.isNotEmpty) {
  await analytics.logEvent(
    name: 'play_audio',
    parameters: {
      'audio_id': audioId.toString(),
      'audio_title': audioTitle,
      // ...
    },
  );
}

// Bad - missing validation
await analytics.logEvent(
  name: 'play_audio',
  parameters: {
    'audio_id': audioId, // Might be null
    // ...
  },
);
```

### 3. Error Handling

Always handle errors gracefully:
```dart
try {
  await analytics.logEvent(
    name: 'play_audio',
    parameters: {...},
  );
} catch (e) {
  // Log error but don't crash app
  debugPrint('Analytics error: $e');
  // Optionally report to Crashlytics
}
```

### 4. Testing

**Development Testing**:
- Enable debug mode in Firebase Console
- Use Firebase Console DebugView to see events in real-time
- Test all events before release

**Production Verification**:
- Check Firebase Console after release
- Monitor event counts to ensure events are firing
- Verify parameter values in sample events

### 5. Privacy & Compliance

- ✅ Only track user actions, not personal information
- ✅ Don't track exact location (use general location if needed)
- ✅ Don't track device IDs without consent
- ✅ Provide clear privacy policy (you already have this)
- ✅ Allow users to opt-out if required by regulations

---

## 📊 Reporting & Analysis

### Key Reports to Create in Firebase Console

1. **User Engagement Dashboard**
   - Daily Active Users
   - Average Session Duration
   - Audio Play Completion Rate
   - Favorite Adoption Rate

2. **Content Performance Report** (Phase 1)
   - Most Played Sounds
   - Most Favorite Sounds
   - Mode Popularity
   - Discovery Source Distribution

**Phase 2**: Additional reports for Feature Adoption (Environment Scan, Timer, Fade Settings) and advanced funnels will be added later.

### Custom Dashboards (Future)

Consider creating custom dashboards for:
- Retention analysis (returning users)
- Content recommendations effectiveness
- Feature usage by user segment
- Time-of-day usage patterns

---

## 🔄 Maintenance & Updates

### Regular Reviews
- **Weekly**: Check event counts and errors
- **Monthly**: Review funnels and conversion rates
- **Quarterly**: Audit events and remove unused ones

### Version Control
- Track changes to tracking plan in git
- Document breaking changes
- Update this document when adding new events

### Migration Notes
- When Firebase Analytics SDK updates, check for deprecated events
- Update implementation accordingly
- Test thoroughly after SDK updates

---

## 📚 Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Flutter Firebase Analytics Package](https://pub.dev/packages/firebase_analytics)
- [GA4 Event Best Practices](https://support.google.com/analytics/answer/9267735)
- [Event Parameter Limits](https://support.google.com/firebase/answer/9234069)

---

## ✅ Checklist

Before implementing tracking:

### Phase 1 Implementation Checklist (MVP)

**Setup & Infrastructure:**
- [ ] Review this tracking plan with team
- [ ] Set up Firebase Analytics in Firebase Console
- [ ] Add `firebase_analytics` package to `pubspec.yaml`
- [ ] Initialize Firebase Analytics in app
- [ ] Create `AnalyticsService` helper class

**Screen Tracking (8 screens):**
- [ ] Add `logScreenView` to `HomeScreen`
- [ ] Add `logScreenView` to `MyTuneView` (with tab tracking)
- [ ] Add `logScreenView` to `SettingsScreen`
- [ ] Add `logScreenView` to `SoundPlayerUI` (when expanded)
- [ ] Add `logScreenView` to `ModeSoundsScreen` (with mode parameters)
- [ ] Add `logScreenView` to `RecordingView` (environment scan screen)
- [ ] Add `logScreenView` to timer settings modal
- [ ] Add `logScreenView` to fade settings modal
- [ ] Add `logScreenView` to tab change handler (bottom navigation)

**Core Events (9 events):**
- [ ] `play_audio` - Primary engagement metric
- [ ] `pause_audio` - User engagement
- [ ] `complete_audio` - Completion tracking
- [ ] `stop_audio` - Early exit tracking (optional)
- [ ] `tap_sound_card` - Content discovery
- [ ] `tap_daily_mode` - Mode selection
- [ ] `view_mode_sounds` - Mode list views
- [ ] `favorite_audio` - User preference
- [ ] `change_tab` - Navigation tracking

**User Properties (6 properties):**
- [ ] `user_type` - User classification
- [ ] `signup_date` - First app open date
- [ ] `total_favorites` - Favorite count
- [ ] `total_sounds_played` - Play count
- [ ] `favorite_genre` - Most liked genre
- [ ] `favorite_mode` - Most used mode

**Funnels & Conversions:**
- [ ] Funnel 1: First Audio Play
- [ ] Funnel 2: Audio Discovery to Play
- [ ] Funnel 3: Favorites Adoption
- [ ] Set up conversion events in Firebase Console

**Testing & Verification:**
- [ ] Test all events in debug mode
- [ ] Verify in Firebase Console DebugView
- [ ] Test screen tracking navigation
- [ ] Verify user properties are set correctly
- [ ] Verify events in production after release

**Phase 2**: Advanced features tracking will be added in a future update.

---

## 📋 Phase 1 Summary

### What's Included (MVP)
- ✅ **8 Screens**: Home, My Tune, Settings, Sound Player, Mode Sounds, Environment Scan, Timer Settings, Fade Settings
  - *Note: Screen tracking included for all screens, but event tracking for Environment Scan, Timer, and Fade Settings will be in Phase 2*
- ✅ **9 Core Events**: play_audio, pause_audio, complete_audio, stop_audio, tap_sound_card, tap_daily_mode, view_mode_sounds, favorite_audio, change_tab
- ✅ **6 User Properties**: user_type, signup_date, total_favorites, total_sounds_played, favorite_genre, favorite_mode
- ✅ **3 Essential Funnels**: First Audio Play, Audio Discovery to Play, Favorites Adoption
- ✅ **3 Conversion Events**: play_audio, complete_audio, favorite_audio

### What's Not Included (Phase 2)
- ❌ Environment Scan events (8 events) - *Screen tracking included in Phase 1*
- ❌ Timer events (4 events) - *Screen tracking included in Phase 1*
- ❌ Fade Settings events (3 events) - *Screen tracking included in Phase 1*
- ❌ Settings events (tap_rate_app, tap_share_app, view_privacy_policy, view_terms_of_use)
- ❌ Advanced content discovery (view_sound_card, view_favorites, view_recents, tap_mini_player, collapse_player)
- ❌ Error & Performance tracking
- ❌ Advanced user properties (behavioral properties, timer/scan usage)

**Estimated Implementation Time**: 2-3 days for Phase 1 MVP

---

**End of Tracking Plan - Phase 1 MVP**

*This document is a living document and should be updated as the app evolves. Last updated: 2024-01-15 (Phase 1 MVP)*