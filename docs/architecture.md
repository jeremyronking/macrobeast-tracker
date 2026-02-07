# Architecture Overview

## Data Flow
Flux-like unidirectional data flow using **Riverpod**.
1.  **Providers (`lib/providers/`)**: Manage global application state (`UserProfile`, `DailyLog`).
2.  **Screens (`lib/screens/`)**: Consume providers via `ConsumerWidget`.
3.  **Services (`lib/services/`)**: Handle external API calls (Gemini AI).

## Folder Structure

```
lib/
├── main.dart           # Entry point
├── models/             # Data classes (Types)
│   └── types.dart
├── providers/          # State Management
│   └── app_state.dart
├── screens/            # UI Pages
│   ├── dashboard_screen.dart
│   ├── food_log_screen.dart
│   ├── add_scan_screen.dart
│   ├── progress_screen.dart
│   └── settings_screen.dart
├── services/           # External APIs
│   └── gemini_service.dart
└── widgets/            # Reusable Components
    ├── macro_ring.dart
    └── food_card.dart
```

## Key Dependencies
- `flutter_riverpod`: State management.
- `google_generative_ai`: Gemini API client.
- `fl_chart`: Data visualization.
- `mobile_scanner`: Camera barcode scanning.
- `shared_preferences`: Local storage (TODO).
