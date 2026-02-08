# MacroBeast Tracker

A macro nutrition tracking app with AI-powered food search and meal suggestions.

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **React 19** | UI framework for building interactive user interfaces |
| **TypeScript** | Adds static typing to JavaScript for better code quality |
| **Vite** | Fast build tool and development server |
| **Tailwind CSS** | Utility-first CSS framework for styling |
| **Recharts** | Charting library for progress graphs |
| **Lucide React** | Icon library |
| **Google Gemini AI** | Powers food search and meal suggestions |

## Project Structure

```
macrobeast-tracker/
├── App.tsx              # Main app component (state + views)
├── index.tsx            # React entry point
├── index.html           # HTML template
├── types.ts             # TypeScript type definitions
├── constants.ts         # Default values and mock data
├── components/
│   ├── Layout.tsx       # Tab navigation wrapper
│   ├── MacroRing.tsx    # Circular progress indicator
│   └── AddScanView.tsx  # Food search/barcode scanning UI
├── services/
│   └── geminiService.ts # Gemini AI API integration
├── manifest.json        # PWA configuration
└── service-worker.js    # Offline caching (PWA)
```

## Architecture Overview

### Data Flow

```
User Action → App.tsx (state) → Component → UI Update
                  ↓
            geminiService.ts → Gemini AI API
```

### Key Concepts

**State Management**: All app state lives in `App.tsx` using React's `useState` hook. This includes:
- `userProfile` - User settings and macro goals
- `dailyLog` - Array of logged food entries
- `waterIntake` - Daily water tracking
- `activeTab` - Current navigation tab

**Components**: Reusable UI pieces in the `components/` folder:
- `Layout` - Provides the bottom navigation bar
- `MacroRing` - SVG-based circular progress charts
- `AddScanView` - Handles food search via AI

**Services**: External API integrations in the `services/` folder:
- `geminiService.ts` - Calls Gemini AI for food lookup and meal ideas

**Types**: All TypeScript interfaces and enums are defined in `types.ts`. Key types:
- `UserProfile` - User data and goals
- `FoodItem` - Nutritional info for a food
- `LogEntry` - A logged food item with timestamp
- `Macros` - Calories, protein, carbs, fat, water

## Run Locally

**Prerequisites:** Node.js (v18+)

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set your Gemini API key in `.env.local`:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```

3. Run the development server:
   ```bash
   npm run dev
   ```

4. Open http://localhost:5173 in your browser

## Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server with hot reload |
| `npm run build` | Build for production (outputs to `dist/`) |
| `npm run preview` | Preview production build locally |

## Features

- **Dashboard**: View daily calorie/macro progress with visual rings
- **Food Log**: See all logged foods for the day
- **Add Food**: Search foods using AI or scan barcodes
- **Progress**: View calorie and weight trends over time
- **Settings**: Toggle dark mode, update weight, change goals

## Getting a Gemini API Key

1. Go to [Google AI Studio](https://ai.studio)
2. Sign in with your Google account
3. Click "Get API Key"
4. Copy the key and add it to your `.env.local` file
