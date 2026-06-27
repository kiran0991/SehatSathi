# Sehat Sathi

Sehat Sathi is a Flutter application for scanning packaged-food ingredient labels, extracting ingredient text with OCR, analyzing ingredient quality and additive risk, and presenting a user-friendly health summary. The project uses Supabase for authentication, storage, database, and Edge Functions, with AI-assisted OCR and ingredient analysis.

## What The App Does

- User sign-in and session management
- Disclaimer and health-profile onboarding
- Camera capture or image upload for ingredient labels
- OCR extraction from label images
- Ingredient analysis with health scoring
- Personalized warnings based on saved profile data

## Technology Stack

### Frontend

- Flutter
- Dart
- Riverpod for state management
- GoRouter for navigation
- `image_picker` for selecting images

### Backend And Infrastructure

- Supabase Authentication
- Supabase Postgres
- Supabase Storage
- Supabase Edge Functions

### AI / OCR Services

- Gemini API for OCR extraction in `supabase/functions/ocr-extract`
- OpenAI API for ingredient analysis and AI-assisted scoring in `supabase/functions/analyze-scan`

## Main Application Modules

- `lib/features/auth`
  Sign-in, sign-up, session handling, and admin detection
- `lib/features/onboarding`
  Disclaimer acceptance and health-profile setup
- `lib/features/scanner`
  Image selection, upload, OCR trigger, and scan workflow
- `lib/features/analysis`
  Ingredient analysis result, score breakdown, and product summary
- `lib/features/history`
  Recent scans and saved result retrieval
- `lib/features/profile`
  Health profile management
- `supabase/functions/ocr-extract`
  OCR pipeline
- `supabase/functions/analyze-scan`
  Ingredient matching, AI assistance, scoring, and result persistence

## Project Structure

```text
lib/
  app/
  core/
  features/
supabase/
  config.toml
  functions/
  migrations/
  seeds/
test/
```

## How Flutter Connects To Supabase

Flutter does not create a Supabase project automatically, and installing Flutter does not provision backend accounts.

### Developer Setup

The developer must first create or already have a Supabase project in the Supabase dashboard. That project provides:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Those values are passed into the Flutter app at runtime with `--dart-define`, and the app uses the Supabase Flutter SDK to connect to that backend.

### End-User Signup And Login

End users do not log into the Supabase dashboard.

Instead, they use the login or sign-up screens inside the Flutter app. The app sends those authentication requests to Supabase Auth for the configured project.

### In Practice

The connection flow is:

1. Developer creates a Supabase project.
2. Developer applies migrations, secrets, and Edge Functions.
3. Developer runs the Flutter app with the correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
4. End user opens the app and signs up or logs in through the app UI.

Without Supabase configuration, the Flutter app may still compile, but authentication, OCR, scan analysis, history, and profile-backed features will not work correctly.

## Local Development

### Prerequisites

Install these before running the project:

- Flutter SDK
- Dart SDK compatible with the Flutter version
- Supabase CLI
- A Supabase project
- Gemini API key
- OpenAI API key

Optional for local Supabase:

- Docker Desktop

### Runtime Configuration

The Flutter app reads these values through `--dart-define`:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

The Supabase Edge Functions require these secrets:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `GEMINI_API_KEY`
- `OPENAI_API_KEY`

### Install Dependencies

From the project root:

```bash
flutter pub get
```

## How To Run The App

### Run On Chrome

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Run On Android

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Run On iOS

```bash
flutter run -d ios --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Common Development Commands

```bash
flutter analyze
flutter test
```

If the app is already running with `flutter run`:

- Hot reload: type `r`
- Hot restart: type `R`
- Stop: `Ctrl + C`

## How To Build The App

### Web Build

```bash
flutter build web --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Android APK

```bash
flutter build apk --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Android App Bundle

```bash
flutter build appbundle --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### iOS Build

```bash
flutter build ios --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## How To Set Up Supabase

### Link The Repo To A Supabase Project

```bash
supabase link --project-ref YOUR_PROJECT_REF
```

### Push Database Migrations

```bash
supabase db push
```

### Set Edge Function Secrets

```bash
supabase secrets set SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
supabase secrets set SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_SUPABASE_SERVICE_ROLE_KEY
supabase secrets set GEMINI_API_KEY=YOUR_GEMINI_API_KEY
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

### Deploy Edge Functions

```bash
supabase functions deploy ocr-extract
```

## How To Run Supabase Locally

These commands require Docker.

### Start Local Supabase

```bash
supabase start
```

### Reset Local Database

```bash
supabase db reset
```

### Serve Functions Locally

```bash
supabase functions serve
```

## Deployment Guide

### Deploy Backend To Staging

1. Link the repo to the staging project.
2. Push migrations.
3. Set or update secrets.
4. Deploy Edge Functions.

Commands:

```bash
supabase link --project-ref YOUR_STAGING_PROJECT_REF
supabase db push
supabase secrets set SUPABASE_URL=https://YOUR_STAGING_PROJECT_REF.supabase.co
supabase secrets set SUPABASE_ANON_KEY=YOUR_STAGING_ANON_KEY
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=YOUR_STAGING_SERVICE_ROLE_KEY
supabase secrets set GEMINI_API_KEY=YOUR_GEMINI_API_KEY
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
supabase functions deploy ocr-extract
```

### Deploy Flutter Web

Build:

```bash
flutter build web --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Then deploy the generated `build/web` folder using your hosting platform of choice.

## Recommended Verification After Deployment

- Sign in successfully
- Complete disclaimer and profile onboarding
- Upload a label image
- Verify OCR returns ingredient tokens
- Verify analysis result page loads
- Verify health score and score breakdown are visible
- Verify scan history saves the new scan

## Notes About Scoring

## Troubleshooting

### Flutter says Supabase is not configured

Run the app with:

```bash
--dart-define=SUPABASE_URL=...
--dart-define=SUPABASE_ANON_KEY=...
```

### `Bucket not found`

Run database migrations so the storage bucket exists:

```bash
supabase db push
```

### `GEMINI_API_KEY not configured`

Set the secret:

```bash
supabase secrets set GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

### OpenAI analysis fails

Set the secret:

```bash
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

### `supabase status` fails with Docker error

That command checks local Supabase services. For remote projects, use:

```bash
supabase link --project-ref YOUR_PROJECT_REF
```

## Useful Commands

```bash
supabase migration list
supabase functions list
git status
flutter pub get
flutter analyze
flutter test
```

## License / Ownership

This repository appears to be an internal application codebase. Update this section if you want to add a formal license or ownership note.
