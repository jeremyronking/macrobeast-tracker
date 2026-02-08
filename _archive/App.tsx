import React, { useState, useEffect } from 'react';
import { Layout } from './components/Layout';
import { MacroRing } from './components/MacroRing';
import { AddScanView } from './components/AddScanView';
import { 
  Trash2, 
  Droplets, 
  Flame, 
  Dumbbell, 
  TrendingUp,
  Moon,
  Sun,
  User,
  ChevronRight,
  BrainCircuit
} from 'lucide-react';
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer 
} from 'recharts';
import { 
  AppTab, 
  UserProfile, 
  LogEntry, 
  FoodItem 
} from './types';
import { DEFAULT_PROFILE, MOCK_HISTORY } from './constants';
import { getMealIdeas } from './services/geminiService';

export default function App() {
  const [activeTab, setActiveTab] = useState<AppTab>(AppTab.DASHBOARD);
  const [userProfile, setUserProfile] = useState<UserProfile>(DEFAULT_PROFILE);
  const [dailyLog, setDailyLog] = useState<LogEntry[]>([]);
  const [waterIntake, setWaterIntake] = useState(0);
  const [isDark, setIsDark] = useState(false);
  const [mealAdvice, setMealAdvice] = useState<string>('');
  const [loadingAdvice, setLoadingAdvice] = useState(false);

  // Initialize theme
  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDark]);

  // Derived daily totals
  const dailyTotals = dailyLog.reduce((acc, entry) => ({
    calories: acc.calories + entry.food.macros.calories,
    protein: acc.protein + entry.food.macros.protein,
    carbs: acc.carbs + entry.food.macros.carbs,
    fat: acc.fat + entry.food.macros.fat,
  }), { calories: 0, protein: 0, carbs: 0, fat: 0 });

  const addFood = (food: FoodItem) => {
    const newEntry: LogEntry = {
      id: Math.random().toString(36),
      food,
      timestamp: Date.now(),
      date: new Date().toISOString().split('T')[0],
    };
    setDailyLog([...dailyLog, newEntry]);
    setActiveTab(AppTab.FOOD_LOG); // Redirect to log after adding
  };

  const removeEntry = (id: string) => {
    setDailyLog(dailyLog.filter(e => e.id !== id));
  };

  const handleGetAdvice = async () => {
    setLoadingAdvice(true);
    const advice = await getMealIdeas(userProfile);
    setMealAdvice(advice);
    setLoadingAdvice(false);
  };

  // --- VIEWS ---

  const Dashboard = () => (
    <div className="p-4 space-y-6">
      <div className="flex justify-between items-center">
        <div>
            <h1 className="text-2xl font-black text-gray-900 dark:text-white tracking-tight">TODAY</h1>
            <p className="text-gray-500 dark:text-gray-400 text-sm">Let's hit those macros, {userProfile.name}.</p>
        </div>
        <button className="p-2 bg-gray-100 dark:bg-dark-800 rounded-full text-gray-600 dark:text-gray-300">
            <User size={20} />
        </button>
      </div>

      {/* Main Calories Ring */}
      <div className="bg-white dark:bg-dark-800 rounded-3xl p-6 shadow-sm border border-gray-100 dark:border-dark-700 flex justify-between items-center">
        <div className="space-y-1">
            <h3 className="font-bold text-3xl dark:text-white">
                {Math.max(0, userProfile.macroGoals.calories - dailyTotals.calories)}
            </h3>
            <p className="text-gray-400 text-sm font-medium uppercase tracking-wide">Calories Left</p>
            <div className="flex items-center gap-1 text-xs text-gray-500 mt-2">
                <Flame size={12} className="text-primary-600" />
                <span>Goal: {userProfile.macroGoals.calories}</span>
            </div>
        </div>
        <MacroRing 
            value={dailyTotals.calories} 
            max={userProfile.macroGoals.calories} 
            color="#dc2626" 
            label="Consumed"
            unit="kcal"
            size="lg"
        />
      </div>

      {/* Macro Rings Row */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white dark:bg-dark-800 p-4 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700 flex flex-col items-center">
            <MacroRing value={dailyTotals.protein} max={userProfile.macroGoals.protein} color="#f59e0b" label="Protein" unit="g" size="sm" />
        </div>
        <div className="bg-white dark:bg-dark-800 p-4 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700 flex flex-col items-center">
            <MacroRing value={dailyTotals.carbs} max={userProfile.macroGoals.carbs} color="#3b82f6" label="Carbs" unit="g" size="sm" />
        </div>
        <div className="bg-white dark:bg-dark-800 p-4 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700 flex flex-col items-center">
            <MacroRing value={dailyTotals.fat} max={userProfile.macroGoals.fat} color="#8b5cf6" label="Fat" unit="g" size="sm" />
        </div>
      </div>

      {/* Water Tracker */}
      <div className="bg-blue-50 dark:bg-blue-900/10 p-5 rounded-2xl border border-blue-100 dark:border-blue-900/30 flex items-center justify-between">
          <div className="flex items-center gap-3">
              <div className="p-3 bg-blue-500 rounded-xl text-white shadow-lg shadow-blue-500/30">
                  <Droplets size={24} />
              </div>
              <div>
                  <h4 className="font-bold text-gray-800 dark:text-blue-100">Water Intake</h4>
                  <p className="text-xs text-gray-500 dark:text-blue-200/60">{waterIntake} / {userProfile.macroGoals.water} ml</p>
              </div>
          </div>
          <button 
            onClick={() => setWaterIntake(prev => prev + 250)}
            className="w-10 h-10 bg-white dark:bg-blue-600 rounded-full flex items-center justify-center text-blue-600 dark:text-white shadow-sm font-bold text-lg"
          >
              +
          </button>
      </div>

      {/* AI Suggestion */}
      <div className="bg-gray-900 dark:bg-black p-5 rounded-2xl shadow-xl text-white relative overflow-hidden">
          <div className="absolute top-0 right-0 p-3 opacity-10">
              <BrainCircuit size={80} />
          </div>
          <h3 className="font-bold text-lg mb-2 z-10 relative">Need Meal Ideas?</h3>
          <p className="text-gray-400 text-sm mb-4 max-w-[80%] z-10 relative">
             Get AI-powered suggestions based on your remaining macros.
          </p>
          {!mealAdvice ? (
              <button 
                onClick={handleGetAdvice}
                disabled={loadingAdvice}
                className="bg-primary-600 text-white px-4 py-2 rounded-lg text-sm font-bold flex items-center gap-2 hover:bg-primary-700 transition-colors z-10 relative"
            >
                {loadingAdvice ? 'Thinking...' : 'Generate Plan'} <ChevronRight size={16} />
              </button>
          ) : (
            <div className="text-xs text-gray-300 bg-gray-800 p-3 rounded-lg mt-2 whitespace-pre-line border border-gray-700 z-10 relative">
                {mealAdvice}
                <button 
                    className="block mt-2 text-primary-500 font-bold underline"
                    onClick={() => setMealAdvice('')}
                >
                    Close
                </button>
            </div>
          )}
      </div>
    </div>
  );

  const FoodLog = () => (
    <div className="p-4 space-y-4">
        <h2 className="text-2xl font-black dark:text-white">Food Log</h2>
        {dailyLog.length === 0 ? (
            <div className="text-center py-20 opacity-50">
                <Dumbbell size={48} className="mx-auto mb-4" />
                <p>No food logged today.</p>
                <button onClick={() => setActiveTab(AppTab.ADD_SCAN)} className="text-primary-600 font-bold mt-2">Start Logging</button>
            </div>
        ) : (
            <div className="space-y-3">
                {dailyLog.map((entry) => (
                    <div key={entry.id} className="bg-white dark:bg-dark-800 p-4 rounded-xl shadow-sm border border-gray-100 dark:border-dark-700 flex justify-between items-center group">
                        <div className="flex-1">
                            <h3 className="font-bold text-gray-800 dark:text-white">{entry.food.name}</h3>
                            <div className="flex gap-3 text-xs text-gray-500 mt-1">
                                <span className="font-mono text-primary-600">{entry.food.macros.calories} kcal</span>
                                <span>P: {entry.food.macros.protein}g</span>
                                <span>C: {entry.food.macros.carbs}g</span>
                                <span>F: {entry.food.macros.fat}g</span>
                            </div>
                        </div>
                        <button 
                            onClick={() => removeEntry(entry.id)}
                            className="p-2 text-gray-300 hover:text-red-500 dark:text-dark-700 dark:hover:text-red-400 transition-colors"
                        >
                            <Trash2 size={20} />
                        </button>
                    </div>
                ))}
            </div>
        )}
         <div className="bg-gray-100 dark:bg-dark-700 p-4 rounded-xl mt-6">
            <h4 className="font-bold text-gray-700 dark:text-gray-200 mb-2">Total Consumed</h4>
            <div className="flex justify-between text-sm dark:text-gray-400">
                <span>Calories: {dailyTotals.calories}</span>
                <span>Protein: {dailyTotals.protein}g</span>
            </div>
         </div>
    </div>
  );

  const Progress = () => (
    <div className="p-4 space-y-6">
        <h2 className="text-2xl font-black dark:text-white">Progress</h2>
        
        {/* Graph 1: Calories History */}
        <div className="bg-white dark:bg-dark-800 p-4 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700">
            <h3 className="font-bold mb-4 dark:text-gray-200 flex items-center gap-2">
                <TrendingUp size={18} className="text-secondary-500" />
                Calorie History
            </h3>
            <div className="h-64 w-full text-xs">
                <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={MOCK_HISTORY}>
                        <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={isDark ? '#3f3f46' : '#e5e7eb'} />
                        <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{fill: isDark ? '#9ca3af' : '#6b7280'}} />
                        <YAxis hide domain={['dataMin - 100', 'dataMax + 100']} />
                        <Tooltip 
                            contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)' }}
                        />
                        <Line 
                            type="monotone" 
                            dataKey="calories" 
                            stroke="#ef4444" 
                            strokeWidth={3} 
                            dot={{ fill: '#ef4444', strokeWidth: 0, r: 4 }} 
                            activeDot={{ r: 6 }} 
                        />
                    </LineChart>
                </ResponsiveContainer>
            </div>
        </div>

        {/* Graph 2: Weight Trend */}
        <div className="bg-white dark:bg-dark-800 p-4 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700">
            <h3 className="font-bold mb-4 dark:text-gray-200">Weight Trend (kg)</h3>
            <div className="h-48 w-full text-xs">
                <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={MOCK_HISTORY}>
                         <CartesianGrid strokeDasharray="3 3" vertical={false} stroke={isDark ? '#3f3f46' : '#e5e7eb'} />
                        <XAxis dataKey="date" axisLine={false} tickLine={false} tick={{fill: isDark ? '#9ca3af' : '#6b7280'}} />
                        <YAxis hide domain={['dataMin - 1', 'dataMax + 1']} />
                        <Tooltip contentStyle={{ borderRadius: '12px', border: 'none' }} />
                        <Line 
                            type="monotone" 
                            dataKey="weight" 
                            stroke="#22c55e" 
                            strokeWidth={3}
                            dot={{ fill: '#22c55e', strokeWidth: 0, r: 4 }} 
                        />
                    </LineChart>
                </ResponsiveContainer>
            </div>
        </div>
        
        {/* Time filters mock */}
        <div className="flex bg-gray-200 dark:bg-dark-700 rounded-lg p-1">
             {['1W', '1M', '3M', '6M', '1Y', 'ALL'].map((tf, idx) => (
                 <button key={tf} className={`flex-1 py-2 text-xs font-bold rounded-md ${idx === 0 ? 'bg-white dark:bg-dark-600 shadow-sm text-black dark:text-white' : 'text-gray-500'}`}>
                     {tf}
                 </button>
             ))}
        </div>
    </div>
  );

  const SettingsTab = () => (
    <div className="p-4 space-y-6">
        <h2 className="text-2xl font-black dark:text-white">Settings</h2>
        
        <div className="bg-white dark:bg-dark-800 rounded-2xl overflow-hidden border border-gray-100 dark:border-dark-700">
            <div className="p-4 border-b border-gray-100 dark:border-dark-700 flex items-center justify-between">
                <span className="font-medium dark:text-white">Dark Mode</span>
                <button 
                    onClick={() => setIsDark(!isDark)}
                    className={`w-14 h-8 rounded-full p-1 transition-colors ${isDark ? 'bg-primary-600' : 'bg-gray-200'}`}
                >
                    <div className={`w-6 h-6 bg-white rounded-full shadow-sm transform transition-transform flex items-center justify-center ${isDark ? 'translate-x-6' : 'translate-x-0'}`}>
                        {isDark ? <Moon size={12} className="text-primary-600" /> : <Sun size={12} className="text-yellow-500" />}
                    </div>
                </button>
            </div>
            <div className="p-4 border-b border-gray-100 dark:border-dark-700">
                <label className="block text-sm text-gray-500 mb-1">Current Weight (kg)</label>
                <div className="flex gap-2">
                    <input 
                        type="number" 
                        value={userProfile.weight} 
                        onChange={(e) => setUserProfile({...userProfile, weight: Number(e.target.value)})}
                        className="bg-gray-50 dark:bg-dark-900 border border-gray-200 dark:border-dark-600 rounded-lg px-3 py-2 w-full dark:text-white"
                    />
                    <button className="bg-secondary-500 text-white px-4 rounded-lg font-bold text-sm">Update</button>
                </div>
            </div>
            <div className="p-4">
                 <label className="block text-sm text-gray-500 mb-2">Goal Type</label>
                 <select 
                    value={userProfile.goalType}
                    onChange={(e) => setUserProfile({...userProfile, goalType: e.target.value as any})}
                    className="w-full bg-gray-50 dark:bg-dark-900 border border-gray-200 dark:border-dark-600 rounded-lg px-3 py-3 dark:text-white"
                 >
                     <option value="LOSE_WEIGHT">Lose Weight</option>
                     <option value="MAINTAIN">Maintain</option>
                     <option value="GAIN_MUSCLE">Gain Muscle</option>
                 </select>
            </div>
        </div>

        <div className="text-center pt-8">
            <p className="text-xs text-gray-400">MacroBeast Tracker v1.0.0</p>
        </div>
    </div>
  );

  return (
    <Layout activeTab={activeTab} onTabChange={setActiveTab}>
      {activeTab === AppTab.DASHBOARD && <Dashboard />}
      {activeTab === AppTab.FOOD_LOG && <FoodLog />}
      {activeTab === AppTab.ADD_SCAN && <AddScanView onAddFood={addFood} />}
      {activeTab === AppTab.PROGRESS && <Progress />}
      {activeTab === AppTab.SETTINGS && <SettingsTab />}
    </Layout>
  );
}