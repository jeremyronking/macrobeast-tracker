export enum GoalType {
  LOSE_WEIGHT = 'LOSE_WEIGHT',
  MAINTAIN = 'MAINTAIN',
  GAIN_MUSCLE = 'GAIN_MUSCLE',
}

export enum ActivityLevel {
  SEDENTARY = 'SEDENTARY',
  LIGHTLY_ACTIVE = 'LIGHTLY_ACTIVE',
  MODERATELY_ACTIVE = 'MODERATELY_ACTIVE',
  VERY_ACTIVE = 'VERY_ACTIVE',
}

export interface UserProfile {
  name: string;
  weight: number; // kg
  height: number; // cm
  age: number;
  gender: 'male' | 'female';
  goalType: GoalType;
  activityLevel: ActivityLevel;
  bmr: number;
  tdee: number;
  macroGoals: Macros;
}

export interface Macros {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  water: number; // ml
}

export interface FoodItem {
  id: string;
  name: string;
  brand?: string;
  servingSize: string;
  macros: Macros;
  isCustom?: boolean;
}

export interface LogEntry {
  id: string;
  food: FoodItem;
  timestamp: number;
  date: string; // YYYY-MM-DD
}

export interface DailySummary {
  date: string;
  consumed: Macros;
  entries: LogEntry[];
}

export type Theme = 'light' | 'dark';

export enum AppTab {
  DASHBOARD = 'DASHBOARD',
  FOOD_LOG = 'FOOD_LOG',
  ADD_SCAN = 'ADD_SCAN',
  PROGRESS = 'PROGRESS',
  SETTINGS = 'SETTINGS',
}