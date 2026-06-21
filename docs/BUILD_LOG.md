# Otic Studio v2 — Build Log

Everything done to fork, clean up, and ship Otic Studio v2.

---

## 1. Origin

Forked from `malinzijeremiah01-lab/Otic-Studio` into `EccentricIvan/otic-studio-v2`.
The original repo's CI was broken (fllama dependency issues with Android build tools).

---

## 2. Changes Made (in order)

### 2.1 Dark Theme
**Commit:** `cd356fd`
- Added `AppTheme.dark` with slate dark palette (#0F172A background, #1E293B surfaces, #334155 borders, #F1F5F9 text)
- Set `themeMode: ThemeMode.dark` as default in `app.dart`
- Files: `lib/core/theme/app_theme.dart`, `lib/app.dart`

### 2.2 Hide Dev Artifacts
**Commit:** `7fb9dc5`
- MockEngine label: "Mock (dev only)" → "Otic AI"
- Removed "[Gemma 3 1B model not loaded — this is a dev placeholder response.]" bracket text, replaced with natural guidance
- LlamaCppEngine: removed "[Desktop AI — llama.cpp FFI wiring coming in Phase 1b]", replaced with user-facing install hint
- Learn screen: engine backend chip hidden behind `kDebugMode` so release builds never show it
- Files: `lib/ai_core/inference/mock_engine.dart`, `lib/ai_core/inference/llama_cpp_engine.dart`, `lib/features/learn/learn_screen.dart`

### 2.3 Fix Text Truncation
**Commit:** `535c71d`
- LearningModeCard: description uses `Expanded` with `maxLines: 3` instead of clipping
- Home grid: lower `childAspectRatio` (0.82 mobile, 0.75 desktop) so cards are taller
- Shortened mode descriptions and path descriptions to fit without mid-word breaks
- LearningPathCard: moved Start button to top-right row beside category badge so title gets full width
- Files: `lib/shared/widgets/learning_mode_card.dart`, `lib/shared/widgets/learning_path_card.dart`, `lib/features/home/home_screen.dart`

### 2.4 Unify Accent Color to Indigo
**Commit:** `54af139`
- All buttons, tab indicators, selected chips, and interactive controls now use `AppColors.primary` (indigo #4F46E5)
- Orange and blue no longer appear as action colors
- Semantic colors kept: green for correct/success feedback, red for errors
- Files: `lib/features/practice/practice_screen.dart`, `lib/features/create/create_screen.dart`, `lib/features/teach/teach_screen.dart`, `lib/features/learn/path/path_detail_screen.dart`, `lib/features/projects/projects_screen.dart`

### 2.5 Reorder Onboarding
**Commit:** `c7f25e4`
- Flow changed from Name → Age → Interests → Style to **Name → Interests → Age → Style**
- Interests grid (the engaging interactive screen) comes right after name
- Age/grade (optional, skippable) moved to step 3
- File: `lib/features/onboarding/onboarding_screen.dart`

### 2.6 Reclaim Vertical Space
**Commit:** `6b9c852`
- `displayLarge`: 48px → 32px (home hero title)
- `headlineLarge`: 28px → 24px (onboarding headings)
- Home hero: collapsed to single line, reduced all gaps
- Section gaps: 48px → 32px everywhere
- Onboarding: reduced top padding, heading-to-body gaps, logo 88px → 64px
- Files: `lib/core/theme/app_theme.dart`, `lib/features/home/home_screen.dart`, `lib/features/onboarding/onboarding_screen.dart`

### 2.7 Create Button Helper Text + Deduplicate Offline Copy
**Commit:** `f855c26`
- Create screen: disabled "Start creating" button now shows contextual hint ("Pick a project type" or "Enter a topic")
- Home subtitle: removed third "offline/no internet" mention — badge says it, onboarding says it strongly
- Files: `lib/features/create/create_screen.dart`, `lib/features/home/home_screen.dart`

### 2.8 Remove fllama Dependency
**Commits:** `65d1a3f`, `5a49762`
- Removed `fllama` from `pubspec.yaml` — it was an experimental test-only dependency causing every CI build to fail
- Deleted `lib/ai_core/llama/fllama_engine.dart` and `lib/features/llama/llama_test_screen.dart`
- Removed `/llama-test` route from router and "Llama Test" nav entry from app shell
- Removed NDK/CMake install and Gradle patching steps from CI workflow
- The main AI pipeline (`flutter_gemma` / LiteRT-LM on Android) is unaffected
- Files: `pubspec.yaml`, `lib/core/router/app_router.dart`, `lib/shared/widgets/app_shell.dart`, `.github/workflows/build-release-artifacts.yml`

### 2.9 Fix CI Build — ProGuard + R8
**Commits:** `6e8e353`, `7abb06c`
- Patched fllama's deprecated `getDefaultProguardFile('proguard-android.txt')` → `proguard-android-optimize.txt` (before fllama was fully removed)
- Added `-dontwarn` ProGuard rules for `javax.lang.model`, `javax.tools`, `autovalue.shaded`, `com.google.auto`, `com.squareup.javapoet`
- File: `android/app/proguard-rules.pro`, `.github/workflows/build-release-artifacts.yml`

### 2.10 Dark Mode Visibility Fixes
**Commits:** `8c9b229`, `41c39c0`, `847a457`, `3fda1ce`
- Home: replaced voice mic button with send arrow
- Learn: fixed suggestion chips invisible in dark mode — theme-aware colors
- Projects: forced white text on "Start a project" button
- Practice: changed topic chips from horizontal scroll to wrapping grid
- Onboarding: switched gradient to dark slate in dark mode, replaced all hardcoded `AppColors.textSecondary/border/surface` with `Theme.of(context)` equivalents
- Fixed `const Text` + `Theme.of(context)` compile errors (can't mix const with runtime calls)
- Files: `lib/shared/widgets/voice_ask_widget.dart`, `lib/features/learn/learn_screen.dart`, `lib/features/projects/projects_screen.dart`, `lib/features/practice/practice_screen.dart`, `lib/features/onboarding/onboarding_screen.dart`

---

## 3. CI/CD Setup

- **Repo:** `https://github.com/EccentricIvan/otic-studio-v2`
- **Workflow:** `.github/workflows/build-release-artifacts.yml`
- **Triggers:** Push to `main`, manual dispatch
- **Jobs:**
  1. Build Android APK (ubuntu-latest, Flutter 3.44.x)
  2. Build Windows EXE (windows-latest)
  3. Publish to rolling `latest-build` release
- **APK download:** `https://github.com/EccentricIvan/otic-studio-v2/releases/download/latest-build/otic-studio-latest.apk`

---

## 4. AI Model Setup

The app uses Google's **Gemma 3 1B** running on-device via LiteRT-LM (formerly MediaPipe).

### How to install the model:
1. Go to [Kaggle — google/gemma-3](https://www.kaggle.com/models/google/gemma-3)
2. Select **LiteRT (formerly TFLite)** tab
3. Choose variation **gemma3-1b-it-int4**
4. Click **"Download model as tar.gz"**
5. Extract the `.tar.gz` — find `gemma3-1B-it-int4.task` (~541 MB)
6. Transfer the `.task` file to your Android phone via USB
7. Open Otic Studio → tap **"Install from file..."** → pick the file
8. Wait for the progress bar — after that, AI responses are real and fully offline

### Model details:
| Field | Value |
|-------|-------|
| Model | Gemma 3 1B Instruction-Tuned |
| Format | LiteRT (`.task`) |
| Quantization | int4 |
| Size | ~541 MB |
| Runtime | LiteRT-LM via `flutter_gemma` |
| Min RAM | 4 GB |
| Internet | Not needed after install |

---

## 5. Architecture (unchanged from original)

- **Framework:** Flutter 3.44+ / Dart
- **State management:** Riverpod (`Provider`, `FutureProvider`, `AsyncNotifier`)
- **Routing:** `go_router` with `ShellRoute`
- **Database:** SQLite via Drift (local, per device)
- **AI:** `flutter_gemma` (Android LiteRT-LM), `LlamaCppEngineImpl` placeholder (desktop), `MockEngine` fallback
- **Font:** Plus Jakarta Sans (bundled, never fetched from network)

### Key directories:
```
lib/
  ai_core/          AI inference, model manager, tutor pipeline
  core/theme/       AppColors, AppTheme (light + dark)
  core/router/      GoRouter with ShellRoute
  db/               Drift tables, DAOs, providers
  features/         All screens (home, learn, practice, create, etc.)
  shared/widgets/   Reusable UI (AppShell, cards, section headers)
```

---

## 6. Color System

| Role | Color | Hex |
|------|-------|-----|
| Primary / Action | Indigo | #4F46E5 |
| Brand / Logo only | Amber | #F59E0B |
| Success / Correct | Emerald | #10B981 |
| Error | Red | #EF4444 |
| Learn mode icon | Indigo | #4F46E5 |
| Practice mode icon | Sky | #0EA5E9 |
| Create mode icon | Amber | #F59E0B |
| Teach mode icon | Emerald | #10B981 |

**Rule:** Indigo is the only action color (buttons, chips, tab indicators). Other colors are for icons/badges/feedback only.

---

## 7. Dark Theme Palette

| Element | Hex |
|---------|-----|
| Background | #0F172A |
| Surface (cards, app bar, nav) | #1E293B |
| Border / Divider | #334155 |
| Primary text | #F1F5F9 |
| Secondary text | #94A3B8 |
| Hint text | #64748B |

---

## 8. Known State

- APK builds and deploys automatically on push to `main`
- Dark theme is the default
- Mock engine provides placeholder responses when no AI model is installed
- Mock responses are user-friendly (no dev jargon)
- Engine badge chip is hidden in release builds
- fllama has been fully removed — no NDK/CMake dependency
- Onboarding flow: Name → Interests → Age/Grade → Learning Style
