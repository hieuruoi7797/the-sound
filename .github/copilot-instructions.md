## Purpose

Short, focused instructions to help an AI coding agent become productive in this Flutter MVVM app (The Sound / `mytune`). Use these patterns and examples when making edits, refactors or generating new features.

## Big picture (what to know first)
- Architecture: Flutter app organized as MVVM (features/<feature>/viewmodels, models, views). State is managed with Riverpod (mostly StateNotifierProviders).
- Core responsibilities live under `lib/core/` (routing, constants, providers). Feature code is under `lib/features/` grouped by feature.
- Audio pipeline: audio playback is handled by a custom `MyAudioHandler` (see `lib/features/sound_player/viewmodels/my_audio_handler.dart`) which wraps `just_audio` + `audio_service` for background playback and fades.
- Firebase: Firebase is used for messaging, realtime database, storage (audio files). Audio files are expected at `sounds/{soundId}.wav` in Firebase Storage; the code falls back to a sound model `url` if Storage lookup fails.
- Network resilience: The app monitors connectivity and queues failed requests (audio/image loads) to retry when connection is restored. See `lib/core/network/` for `ConnectivityService` and `RequestQueueService`.

## Key files and examples
- `lib/main.dart` — app bootstrap: Firebase initialization, FCM background handler, ProviderScope overrides (e.g., `sharedPreferencesProvider`), route setup via `core/routes`, localization wiring, and wraps app with `ConnectivityListener`.
- `lib/features/sound_player/viewmodels/soundplayer_view_model.dart` — example patterns to follow:
  - Provider declaration: `final soundPlayerProvider = StateNotifierProvider<SoundPlayerViewModel, SoundPlayerState>((ref) => ...)`.
  - Cross-provider listening: `_ref.listen<SettingsState>(settingsViewModelProvider, ...)` — prefer Riverpod `Ref.listen` for reacting to other providers.
  - Race-avoidance: uses `_loadToken` to ignore stale async loads when showing/setting audio.
  - Firebase Storage logic: builds path `sounds/${sound.soundId}.wav`, attempts `FirebaseStorage.instance.ref().child(path).getDownloadURL()` and falls back to `sound.url` on failure.
  - **Network integration**: checks connectivity before loading, queues failed requests to `RequestQueueService` with fallback messaging.
  - Persistence: recents/favorites saved via `SharedPreferences` as JSON string lists using keys from `core/constants/app_strings.dart`.
- `lib/core/network/` — network resilience services:
  - `connectivity_service.dart`: monitors internet status via `connectivity_plus`; exposes `connectivityStream` and `checkConnectivity()`.
  - `request_queue_service.dart`: manages queue of failed requests with retry logic; exposed as `requestQueueServiceProvider`.
  - `network_providers.dart`: Riverpod providers for connectivity and queue services.
- `lib/core/widgets/connectivity_listener.dart` — global widget that shows offline banner when no internet.

## Conventions and patterns
- File layout: `lib/features/<feature>/(models|viewmodels|views)` — keep that structure for new features.
- Provider naming: use `snake_caseNameProvider` (e.g., `soundPlayerProvider`) and expose StateNotifier classes named `XxxViewModel` with a corresponding immutable State class `XxxState`.
- Long-lived subscriptions: ViewModels often create StreamSubscriptions and Timers — ensure `dispose()` cancels subscriptions and timers (see `dispose()` in `SoundPlayerViewModel`).
- **Network-aware operations**: When loading remote resources (audio, images), check connectivity first and queue on failure:
  ```dart
  final connectivityService = _ref.read(connectivityServiceProvider);
  final isConnected = await connectivityService.checkConnectivity();
  if (!isConnected) {
    final queueService = _ref.read(requestQueueServiceProvider);
    await queueService.queueRequest(
      resourceType: 'audio',
      resourceUrl: sound.url,
      request: () => setAudio(sound, loadToken),
    );
    return;
  }
  ```
- Avoid editing generated files under `build/` or `flutter_gen/` — update source (l10n.yaml, arb files) and rebuild.

## Build / run / debug (concrete commands)
- Fetch deps: `flutter pub get` (after adding `connectivity_plus` to pubspec, or after any dependency change).
- Run app: `flutter run -d <device>` (Android/iOS devices require platform-specific firebase config: `android/app/google-services.json`, iOS plist settings and pods).
- iOS pods: `cd ios && pod install` if you change native iOS deps (connectivity_plus requires native setup).
- Clean if native plugin issues occur: `flutter clean && flutter pub get` then full restart (not hot reload) — see README for MissingPluginException steps.
- Tests: `flutter test` (there is a `test/widget_test.dart`).

## Localization and code generation
- Localizations: `l10n.yaml` exists; generated localization code is imported as `package:flutter_gen/gen_l10n/app_localizations.dart`. Edit ARB files and run a normal `flutter pub get` / build to regenerate. Do not edit generated files directly.

## Firebase & platform notes
- Firebase init and FCM: `main.dart` calls `Firebase.initializeApp()` and registers `FirebaseMessaging.onBackgroundMessage(...)`. When editing push/notification code, keep background handler as a top-level `Future<void>` function.
- Audio storage path: use `sounds/{soundId}.wav` when uploading to Firebase Storage for compatibility with the app's retrieval logic.
- Connectivity on native platforms: `connectivity_plus` is platform-agnostic but requires native permissions/setup on iOS/Android (handled by the package).

## Safety & small gotchas (from codebase)
- Race conditions when loading audio: follow existing `_loadToken` pattern if you add async audio-loading logic.
- For audio looping the viewmodel constructs a `ConcatenatingAudioSource` with repeated URIs — prefer that over manual restart logic.
- When changing providers that are overridden in `main.dart` (e.g., `sharedPreferencesProvider`), update the `ProviderScope` overrides accordingly.
- **Queuing infinite loops**: The `RequestQueueService` has a max retry limit (default 3). If a queued request always fails, it is removed after max retries to prevent infinite loops. Monitor logs for `[RequestQueue]` entries.
- **Connectivity changes during queue processing**: If connectivity drops while processing the queue, failed requests stay in queue. When connection restores, `SoundPlayerViewModel` triggers queue processing automatically via the connectivity listener.

## Where to look for more context
- `lib/core/` — constants, route names, network services, and shared providers.
- `lib/features/*/viewmodels` — canonical ViewModel examples (follow `SoundPlayerViewModel` and `UserViewModel`).
- `pubspec.yaml` — dependency list (Riverpod, just_audio, audio_service, firebase_*, shared_preferences, connectivity_plus).
- `lib/main.dart` — app initialization and ProviderScope setup.

If anything here is unclear or you'd like additional examples (how to handle image loading with queue, unit tests for network services, or more deep-dive into the audio handler), tell me which area to expand and I'll iterate.

