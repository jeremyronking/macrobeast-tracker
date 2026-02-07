# MacroBeast Tracker (Flutter)

A mobile-first Progressive Web App (PWA) designed for tracking nutritional intake (macros) with the help of AI.

## 📂 Project Structure

- `flutter_app/`: The main application code (Flutter).
- `_archive/`: The original React codebase (for reference).
- `docs/`: Project documentation.
- `GEMINI.md`: Contextual documentation for AI development.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (check with `flutter --version`)
- CocoaPods (for iOS)
- Android Studio / Xcode

### Setup

1.  **Navigate to the app directory:**
    ```bash
    cd flutter_app
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Configuration:**
    Create a `.env` file in `flutter_app/` with your API key:
    ```bash
    # flutter_app/.env
    GEMINI_API_KEY=your_api_key_here
    ```

### Running the App

Run the application with the environment configuration loaded:

```bash
flutter run --dart-define-from-file=.env
```

## 📚 Documentation

- [Architecture Overview](docs/architecture.md)
- [Building for iOS](docs/ios_build.md)

## 🛠 Features

- **Dashboard:** Track daily macros and get AI meal suggestions.
- **Food Log:** Manage daily intake.
- **Add/Scan:** AI-powered food search and barcode scanning.
- **Progress:** visualize calorie and weight history.
- **Settings:** Dark mode support and profile management.
