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

## 8. Gemma Integration (resolved)

### What worked
- **Gemma 2 2B GPU int8** model (`.bin` format from Kaggle) loads and runs
- `flutter_gemma` 1.0.2 + `flutter_gemma_mediapipe` 1.0.0
- `FlutterGemma.initialize()` called in `main()` with `MediaPipeEngine()`
- `FlutterGemma.installModel().fromFile(path).install()` for loading
- `InferenceModel.createChat()` + `generateChatResponseAsync()` for streaming
- `response.token` extracts clean text (not `response.toString()`)
- Responses are real, coherent, and contextual

### What didn't work
- **Gemma 3 `.task` file**: "Error building tflite model" — MediaPipe can't parse Gemma 3 format
- **flutter_gemma 0.4.6**: `loadAssetModel` throws "should not be used in release build"
- **flutter_gemma 1.0.2 initial attempt**: wrong API calls (`Message.text()` positional args, `response.text` getter)
- Multiple CI failures from API mismatches, const+Theme.of conflicts, missing engine registration

### Model install steps
1. Download **gemma-2-tflite-gemma2-2b-it-gpu-int8** from Kaggle (LiteRT tab)
2. Extract `.bin` file from tar.gz (~2.1 GB)
3. Transfer to phone via USB
4. Open app → Learn → "Install from file..." → pick the `.bin` file
5. Wait for progress bar → AI is live

### Performance notes
- First response is slowest (model loading into memory)
- Typical response time: 10-30 seconds on 6GB RAM Samsung
- Low battery causes throttling — charge the phone for best speed
- Duplicate follow-up prompts in tutor pipeline (minor polish issue)

---

## 9. Additional changes after initial build

### 2.11 Ollama Engine (optional)
**Commit:** `0e9fbf2`
- Added `OllamaEngine` that connects to local Ollama server at `localhost:11434`
- Added `network_security_config.xml` for localhost HTTP access
- Added `http` package dependency
- Currently not the default engine — available as a future option
- File: `lib/ai_core/inference/ollama_engine.dart`

### 2.12 FlutterGemma.initialize() in main
**Commit:** `f8b8f89`
- Required by flutter_gemma 1.0.2 before any plugin usage
- Registers `MediaPipeEngine()` for `.task`/`.bin` model files
- File: `lib/main.dart`

### 2.13 Fix response.token extraction
**Commit:** `a545640`
- `response.toString()` returned `TextResponse("word")` as raw text
- Fixed to use `response.token` for clean text output
- File: `lib/ai_core/inference/litert_lm_engine.dart`

### 2.14 ModelGate restored on Learn route
**Commit:** `e1701b7`
- Removed and re-added multiple times during debugging
- Final state: ModelGate wraps Learn route to show install screen
- Engine provider checks model status, falls back to MockEngine
- Files: `lib/core/router/app_router.dart`, `lib/ai_core/providers/ai_provider.dart`

### 2.15 Engine factory reverted to LiteRT primary
**Commit:** `213247a`
- Ollama was temporarily set as primary engine, causing errors on Practice/Create
- Reverted to LiteRtLmEngineImpl (Android) / LlamaCppEngineImpl (desktop)
- File: `lib/ai_core/inference/inference_engine.dart`

### 2.16 Remove Guest Demo badge and Sign in button
**Commit:** `9549da7`
- Removed "Guest Demo" badge and "Sign in" button from home app bar
- Clean app bar with just the logo
- File: `lib/features/home/home_screen.dart`

---

## 10. Known State (final)

- APK builds and deploys automatically on push to `main`
- Dark theme is the default
- **Gemma 2 2B GPU model runs on-device** with real AI responses
- MockEngine provides clean fallback when no model is installed
- Engine badge chip is hidden in release builds
- fllama has been fully removed — no NDK/CMake dependency
- Onboarding flow: Name → Interests → Age/Grade → Learning Style
- All action elements use indigo (#4F46E5) as the single accent color
- Guest Demo badge and Sign in button removed
- Text truncation fixed across all cards
- Ollama engine available as optional alternative

---

## 11. Known Issues / Future Polish

- Duplicate follow-up prompt in tutor pipeline responses
- Some responses take 10-30 seconds (normal for on-device 2B model)
- Onboarding text visibility could use further dark mode testing
- Practice/Create/Teach screens still have some hardcoded light-mode colors
