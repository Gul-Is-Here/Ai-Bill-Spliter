# AI Bill Splitter

Scan a receipt, split it fairly (equal, by item, or by percentage), settle up across trips and groups.
Flutter · MVVM + GetX · Firebase (Auth, Firestore, Storage, Functions, App Check, Crashlytics, Analytics, Remote Config) · Gemini.

## Project layout

```
lib/
  main_dev.dart / main_prod.dart   flavor entry points (main.dart = dev)
  app/        bootstrap, config (flavors), bindings, routes, theme, translations (en, ur)
  core/       constants, errors, services (connectivity, analytics, cache, remote config,
              permissions, functions client), utils (money, validators), shared widgets
  features/   auth, scan, split, share, history, groups, voice, settings, home, bill (shared models/repo)
              each: models/ repositories/ services/ viewmodels/ views/ widgets/ bindings/ (only where used)
functions/    Cloud Functions (TypeScript): scanReceipt, parseVoiceSplit, deleteAccount
firestore.rules  storage.rules  firestore.indexes.json  firebase.json
docs/         privacy policy, terms, Play Store listing draft
```

Money is always stored as integer minor units (paisa/cents). Split math lives in
`features/split/services/split_calculator.dart` and always sums exactly to the bill total.

## 1. Firebase setup (once per flavor)

Create two Firebase projects, e.g. `ai-bill-splitter-dev` and `ai-bill-splitter-prod`, on the **Blaze** plan (Functions + Secret Manager need it).

In each project enable: Authentication (Email/Password + Google), Firestore, Storage, App Check, Crashlytics, Analytics, Remote Config.

Register the Android apps and download `google-services.json`:

| Flavor | Package name | File location |
|---|---|---|
| dev  | `com.aibillsplierapp.app.dev` | `android/app/src/dev/google-services.json` |
| prod | `com.aibillsplierapp.app`     | `android/app/src/prod/google-services.json` |

Add the SHA-1 and SHA-256 of your debug key (dev) and your upload key + Play App Signing key (prod) to each Android app; Google Sign-In and Play Integrity depend on them:

```bash
cd android && ./gradlew signingReport
```

The Gradle Google Services and Crashlytics plugins switch on automatically once those files exist.

### App Check
- **prod:** App Check → Apps → Android → Play Integrity → register (needs the Play App Signing SHA-256).
- **dev:** run the app once, copy the debug token from logcat (`DebugAppCheckProvider`), add it under App Check → Manage debug tokens.
- Then enforce App Check for Firestore and Storage. `parseVoiceSplit` and `deleteAccount` set `enforceAppCheck: true`; `scanReceipt` does not (it relies on sign-in + the daily scan limit).

### Remote Config
Create parameter `min_build_number` (number, default `0`). Raise it above an old build number to force users of that build to update.

### Rules, indexes, functions

```bash
npm i -g firebase-tools
firebase login
firebase use --add            # alias the dev and prod projects

# Gemini key lives only in Secret Manager
firebase functions:secrets:set GEMINI_API_KEY      # paste key from https://aistudio.google.com/apikey

cd functions && npm ci && npm test && cd ..
firebase deploy --only firestore:rules,firestore:indexes,storage,functions
```

Daily limits (20 scans, 20 voice splits per user) are in `functions/src/rateLimit.ts`.

## 2. Run

```bash
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart
```

## 3. Tests

```bash
flutter analyze
flutter test                       # split math, settlement, JSON parsing, voice, l10n, widget tests
cd functions && npm test           # AI response schema validation
```

## 4. Release

Create the upload key once and keep it outside the repo:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

`android/key.properties` (git-ignored):

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/Users/you/upload-keystore.jks
```

Bump `version:` in `pubspec.yaml` (the `+N` build number must increase on every upload), then:

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart --release \
  --obfuscate --split-debug-info=build/symbols \
  --dart-define=SUPPORT_EMAIL=you@yourdomain.com
```

Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`.
Upload obfuscation symbols so Crashlytics stack traces are readable:

```bash
firebase crashlytics:symbols:upload --app=<prod Android app id> build/symbols
```

Regenerate icons/splash after changing `assets/icon/*`:

```bash
dart run flutter_launcher_icons && dart run flutter_native_splash:create
```
# Ai-Bill-Spliter
