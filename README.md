# P-Drive Cloud Storage

P-Drive is a private cloud storage application powered by Telegram as a secure backend storage system. Built using Flutter and Supabase, it leverages the **Warm Minimalist Cloud** design system created on Stitch.

## Features

- **Telegram-Powered Backend**: Secure, unlimited cloud storage using Telegram channel/bot integration.
- **Supabase User Profiles**: Seamless authentication and user synchronization.
- **Warm Minimalist Design**: Premium, homely, and clean interface featuring custom bento-grid layouts, soft tonal shifts, and typography centered around the *Inter* font.
- **Transformable Login/Signup Button**: Smooth morphing animations transitioning from text to a circular loader/arrow, and finally a rotating checkmark upon successful operation (inspired by native Telegram Android codebase).
- **Telegram Theme Switcher**: Sleek Telegram-style circular reveal transition when swapping between light and dark modes.
- **Onboarding Flow**: Beautiful 3-step segmented onboarding flow:
  1. **User Profile Setup** (Name input & illustration)
  2. **Storage Preferences** (Bento-grid selections for file types)
  3. **Discovery Information** (Questionnaire options)
- **File Chunking Pipeline**: Segmented file upload/download pipeline allowing transfer of files larger than Telegram's standard bot limits.

## Author

- **Sarwar Altaf Dar**

## Technologies Used

- **Framework**: Flutter (Dart)
- **State Management**: Flutter Riverpod
- **Routing**: GoRouter
- **Authentication/Storage Sync**: Supabase Flutter
- **Animations**: Flutter Animate
- **Icons**: Lucide Icons (Flutter Lucide)
- **Fonts**: Google Fonts (Inter, Plus Jakarta Sans)
- **CI/CD**: GitHub Actions (Automatic Android APK compiler)
