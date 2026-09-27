# MediCare - Native Mobile Application (Flutter & Dart)

> **Your medicines. Your schedule. Your health.**

MediCare is a modern, clean, and accessible mobile medicine reminder and medication information application built with **Flutter**, **Dart**, and **Material 3**.

---

## 📱 Features

- **Personalized Medication Reminders**: Schedule doses with custom times, frequencies, and durations.
- **Smart Dose Logging**: Log medicines as Taken, Skipped, or Snooze alerts (10m, 30m, 1h).
- **Daily Adherence Tracking**: Real-time progress indicators and adherence analytics.
- **Comprehensive Medicine Guide**: Searchable educational drug library with precautions, dosages, warnings, and side-effects.
- **Multi-step Account Setup**: Quick profile configuration and medication preference onboarding.
- **Accessible & High-Contrast Design**: Material 3 typography and touch targets tailored for older adults and clarity.
- **Local State Architecture**: Encapsulated in `LocalStorageService` ready for effortless Firebase / REST API integration.

---

## 📁 Flutter Project Architecture

```text
lib/
├── main.dart                                    # Flutter App Entry Point
├── app.dart                                     # MaterialApp, Theming, and Root Router
│
├── models/                                      # Strongly-Typed Dart Models
│   ├── user.dart                                # User Profile Model
│   ├── medicine.dart                            # Medicine Definition Model
│   ├── medication_log.dart                      # Daily Medication Log & Statuses
│   ├── reminder.dart                            # Scheduled Reminder Model
│   └── medicine_info.dart                       # Educational Drug Information Model
│
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart                  # Onboarding Brand Landing
│   │   ├── login_screen.dart                    # Native Auth & Validation
│   │   ├── create_account_screen.dart           # 3-Step Guided Registration
│   │   └── forgot_password_screen.dart          # Recovery Flow
│   │
│   ├── home/
│   │   ├── main_navigation_shell.dart           # Persistent 5-Tab NavigationBar
│   │   └── home_screen.dart                     # Daily Progress, Next Reminder, Quick Actions
│   │
│   ├── medicines/
│   │   ├── medicines_screen.dart                # Filterable Inventory (Active/Paused/Completed)
│   │   ├── add_medicine_screen.dart             # Dynamic Form with Schedule & Native Pickers
│   │   └── medicine_details_screen.dart         # Detailed Specs & Dose History
│   │
│   ├── history/
│   │   └── history_screen.dart                  # Adherence Dashboard (Today, Week, Month)
│   │
│   ├── information/
│   │   ├── medicine_information_screen.dart     # Searchable Healthcare Knowledge Base
│   │   └── medicine_info_details_screen.dart    # Uses, Dosages, Warnings, & Precautions
│   │
│   └── profile/
│       ├── profile_screen.dart                  # User Profile, Dark Mode, & App Settings
│       ├── edit_profile_screen.dart             # Profile Editor
│       └── notification_settings_screen.dart    # Granular Sound & Alert Toggles
│
├── widgets/                                     # Reusable Modular UI Components
│   ├── medicine_card.dart
│   ├── reminder_card.dart
│   ├── progress_card.dart
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── empty_state_widget.dart
│
├── services/
│   └── local_storage_service.dart               # Reactive Service Abstraction
│
└── theme/
    └── app_theme.dart                           # Material 3 Color Schemes & Accessible Typography
```

---

## 🚀 How to Run in Flutter

Ensure you have Flutter installed:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run on an Android device or emulator:

```bash
flutter run
```

Build the release APK:

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
