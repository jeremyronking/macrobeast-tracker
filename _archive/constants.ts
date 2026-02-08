import { UserProfile, GoalType, ActivityLevel } from './types';

export const DEFAULT_PROFILE: UserProfile = {
  name: "New User",
  weight: 75,
  height: 175,
  age: 25,
  gender: 'male',
  goalType: GoalType.MAINTAIN,
  activityLevel: ActivityLevel.MODERATELY_ACTIVE,
  bmr: 1750,
  tdee: 2700,
  macroGoals: {
    calories: 2500,
    protein: 180,
    carbs: 250,
    fat: 80,
    water: 3000,
  },
};

export const MOCK_HISTORY = [
    { date: 'Mon', calories: 2100, weight: 75.2 },
    { date: 'Tue', calories: 2300, weight: 75.0 },
    { date: 'Wed', calories: 2500, weight: 75.1 },
    { date: 'Thu', calories: 1950, weight: 74.9 },
    { date: 'Fri', calories: 2400, weight: 74.8 },
    { date: 'Sat', calories: 2800, weight: 75.3 },
    { date: 'Sun', calories: 2200, weight: 75.1 },
];