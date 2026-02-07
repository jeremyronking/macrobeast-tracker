# MacroBeast Tracker - Project Context
> [!IMPORTANT]
> **This project has been migrated to Flutter.**
> The active codebase is in `flutter_app/`. See [README.md](README.md) and [docs/](docs/) for the latest information.
> The content below refers to the archived React application (`_archive/`).

This document provides instructional context for working on the MacroBeast Tracker codebase.

## Project Overview
MacroBeast Tracker is a mobile-first Progressive Web App (PWA) designed for tracking nutritional intake (macros) with the help of AI. It leverages Google's Gemini AI to simplify food logging and provide personalized meal suggestions.

### Core Technologies
- **Framework:** React 19 (Functional Components with Hooks)
- **Language:** TypeScript
- **Build Tool:** Vite
- **Styling:** Tailwind CSS (CDN-based configuration in `index.html`)
- **AI:** Google Gemini (`@google/genai`)
- **Charts:** Recharts (for progress visualization)
- **Icons:** Lucide React
- **Scanning:** `html5-qrcode` (loaded via CDN)

## Building and Running
The project follows standard Node.js/Vite patterns.

1.  **Setup Environment:**
    Create a `.env.local` file and add your Gemini API key:
    ```env
    GEMINI_API_KEY=your_api_key_here
    ```
2.  **Install Dependencies:**
    ```bash
    npm install
    ```
3.  **Start Development Server:**
    ```bash
    npm run dev
    ```
    The app runs by default on `http://localhost:3000`.
4.  **Production Build:**
    ```bash
    npm run build
    ```

## Project Structure and Architecture

### Main Components
- **`App.tsx`**: The central "State Hub" of the application. It manages user profiles, daily logs, water intake, and routing between tabs.
- **`services/geminiService.ts`**: Encapsulates all AI-related logic, including food search, barcode simulation, and meal idea generation using the `gemini-3-flash-preview` model.
- **`components/`**:
  - `Layout.tsx`: Bottom navigation and shell.
  - `MacroRing.tsx`: SVG-based circular progress visualization for macros.
  - `AddScanView.tsx`: Interface for AI food search and barcode scanning.
- **`types.ts`**: Global TypeScript interfaces (e.g., `UserProfile`, `FoodItem`, `LogEntry`).
- **`constants.ts`**: Contains initial state and mock data for development.

### Data Flow
1.  **Input:** User searches for food in `AddScanView`.
2.  **AI Service:** `geminiService.ts` calls Gemini API to parse the query into nutritional data.
3.  **State Update:** `App.tsx` receives the food item and updates the `dailyLog` state.
4.  **Visualization:** `Dashboard` and `MacroRing` components re-render based on the updated totals.

## Development Conventions

### Styling
The project uses **Tailwind CSS** via a CDN script in `index.html`. 
- **Dark Mode:** Supported using the `dark:` class modifier. Theme state is managed in `App.tsx`.
- **Custom Colors:** Configured in `index.html` (primary, secondary, dark).
- **Responsive Design:** Focused on a mobile-first, native-app feel (overscroll disabled, no-scrollbar utility).

### State Management
State is purposefully kept local to `App.tsx` and passed down via props. For a project of this scale, this keeps the architecture simple and readable.

### AI Guidelines
- When adding new AI features, update `services/geminiService.ts`.
- Prefer structured JSON outputs from Gemini using `responseMimeType: "application/json"` and `responseSchema` for reliability.
- The project currently uses `gemini-3-flash-preview` for its speed and cost-efficiency.

### Types
Always maintain strict typing in `types.ts`. Any new data structures should be added there before being used in components or services.
