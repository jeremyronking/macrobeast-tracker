import React, { useState, useEffect, useRef } from 'react';
import { Search, Camera, ScanLine, X, Plus } from 'lucide-react';
import { FoodItem } from '../types';
import { searchFoodAI, identifyBarcodeFood } from '../services/geminiService';

interface AddScanViewProps {
  onAddFood: (food: FoodItem) => void;
}

export const AddScanView: React.FC<AddScanViewProps> = ({ onAddFood }) => {
  const [activeMode, setActiveMode] = useState<'search' | 'scan' | 'create'>('search');
  const [searchQuery, setSearchQuery] = useState('');
  const [searchResults, setSearchResults] = useState<FoodItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [isCameraActive, setIsCameraActive] = useState(false);
  const scannerRef = useRef<any>(null);

  // Custom food form state
  const [customFood, setCustomFood] = useState({ name: '', calories: '', protein: '', carbs: '', fat: '' });

  const handleSearch = async () => {
    if (!searchQuery.trim()) return;
    setLoading(true);
    const results = await searchFoodAI(searchQuery);
    setSearchResults(results);
    setLoading(false);
  };

  const startCamera = async () => {
    setIsCameraActive(true);
    // Give DOM time to render the reader element
    setTimeout(() => {
        if(!(window as any).Html5Qrcode) {
            alert("Scanner library not loaded.");
            setIsCameraActive(false);
            return;
        }

        const html5QrCode = new (window as any).Html5Qrcode("reader");
        scannerRef.current = html5QrCode;

        const config = { fps: 10, qrbox: { width: 250, height: 250 } };
        
        html5QrCode.start(
            { facingMode: "environment" }, 
            config,
            onScanSuccess,
            (errorMessage: any) => {
                // Parse errors are common, ignore them to keep UI clean
            }
        ).catch((err: any) => {
            console.error(err);
            setIsCameraActive(false);
            alert("Could not start camera. Please ensure you gave permission.");
        });
    }, 100);
  };

  const stopCamera = async () => {
    if (scannerRef.current) {
        try {
            await scannerRef.current.stop();
            await scannerRef.current.clear();
        } catch(e) {
            console.warn("Failed to stop scanner", e);
        }
        scannerRef.current = null;
    }
    setIsCameraActive(false);
  };

  const onScanSuccess = async (decodedText: string, decodedResult: any) => {
      // Stop scanning immediately
      await stopCamera();
      
      setLoading(true);
      try {
          // Pass the REAL barcode to the AI service
          const result = await identifyBarcodeFood(decodedText);
          if(result) {
              onAddFood(result);
              alert(`Found: ${result.name}`);
          } else {
              alert("Could not identify food from barcode.");
          }
      } catch (e) {
          alert("Error identifying food.");
      } finally {
          setLoading(false);
      }
  };

  // Cleanup on unmount
  useEffect(() => {
      return () => {
          if(scannerRef.current) {
              try {
                  scannerRef.current.stop(); 
              } catch(e) {}
          }
      };
  }, []);

  const handleCreateCustom = () => {
      const food: FoodItem = {
          id: Math.random().toString(36),
          name: customFood.name || "Custom Food",
          servingSize: "1 serving",
          macros: {
              calories: Number(customFood.calories),
              protein: Number(customFood.protein),
              carbs: Number(customFood.carbs),
              fat: Number(customFood.fat),
              water: 0
          },
          isCustom: true
      };
      onAddFood(food);
      setCustomFood({ name: '', calories: '', protein: '', carbs: '', fat: '' });
      alert("Custom food added!");
  };

  return (
    <div className="p-4 space-y-6">
      {/* Mode Switcher */}
      <div className="flex bg-gray-200 dark:bg-dark-800 rounded-lg p-1">
        {(['search', 'scan', 'create'] as const).map((mode) => (
          <button
            key={mode}
            onClick={() => {
                if(mode !== 'scan') stopCamera();
                setActiveMode(mode);
            }}
            className={`flex-1 py-2 text-sm font-medium rounded-md capitalize transition-all ${
              activeMode === mode
                ? 'bg-white dark:bg-primary-600 text-primary-600 dark:text-white shadow-sm'
                : 'text-gray-500 dark:text-gray-400'
            }`}
          >
            {mode}
          </button>
        ))}
      </div>

      {/* SEARCH MODE */}
      {activeMode === 'search' && (
        <div className="space-y-4">
          <div className="relative">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
              placeholder="Search food (e.g., Chicken Breast)"
              className="w-full pl-10 pr-4 py-3 bg-white dark:bg-dark-800 border border-gray-200 dark:border-dark-700 rounded-xl focus:ring-2 focus:ring-primary-500 outline-none transition-all dark:text-white"
            />
            <Search className="absolute left-3 top-3.5 text-gray-400" size={20} />
            <button
                onClick={handleSearch}
                disabled={loading}
                className="absolute right-2 top-2 bg-primary-600 text-white px-3 py-1.5 rounded-lg text-sm font-medium"
            >
                {loading ? '...' : 'Go'}
            </button>
          </div>

          <div className="space-y-3">
            {searchResults.map((food) => (
              <div key={food.id} className="bg-white dark:bg-dark-800 p-4 rounded-xl shadow-sm border border-gray-100 dark:border-dark-700 flex justify-between items-center">
                <div>
                  <h3 className="font-bold text-gray-800 dark:text-white">{food.name}</h3>
                  <p className="text-xs text-gray-500">{food.brand} • {food.servingSize}</p>
                  <div className="flex gap-2 mt-1 text-xs font-mono text-gray-600 dark:text-gray-400">
                    <span className="text-primary-600">{food.macros.calories} kcal</span>
                    <span>P: {food.macros.protein}g</span>
                    <span>C: {food.macros.carbs}g</span>
                    <span>F: {food.macros.fat}g</span>
                  </div>
                </div>
                <button
                  onClick={() => onAddFood(food)}
                  className="p-2 bg-secondary-500 bg-opacity-10 text-secondary-500 rounded-full hover:bg-opacity-20 transition-colors"
                >
                  <Plus size={20} />
                </button>
              </div>
            ))}
            {searchResults.length === 0 && !loading && (
                <div className="text-center text-gray-400 mt-10">
                    Search for a food to see results.
                </div>
            )}
          </div>
        </div>
      )}

      {/* SCAN MODE */}
      {activeMode === 'scan' && (
        <div className="flex flex-col items-center space-y-4 h-full">
            {!isCameraActive ? (
                <button 
                    onClick={startCamera}
                    className="flex flex-col items-center justify-center w-full h-64 bg-gray-100 dark:bg-dark-800 rounded-2xl border-2 border-dashed border-gray-300 dark:border-dark-600"
                >
                    <Camera size={48} className="text-gray-400 mb-2" />
                    <span className="text-gray-500">Tap to start camera</span>
                </button>
            ) : (
                <div className="relative w-full rounded-2xl overflow-hidden bg-black">
                    <div id="reader" className="w-full h-full"></div>
                    
                    {loading && (
                        <div className="absolute inset-0 bg-black bg-opacity-70 flex items-center justify-center z-10">
                            <span className="text-white font-bold animate-pulse">Analysing Barcode...</span>
                        </div>
                    )}
                     <button onClick={stopCamera} className="absolute top-4 right-4 bg-black bg-opacity-50 text-white p-2 rounded-full z-20">
                        <X size={20} />
                    </button>
                </div>
            )}
            
            <div className="text-xs text-center text-gray-500 mt-4">
                Point camera at a barcode to automatically scan.
            </div>
        </div>
      )}

      {/* CREATE MODE */}
      {activeMode === 'create' && (
        <div className="space-y-4 bg-white dark:bg-dark-800 p-6 rounded-2xl shadow-sm border border-gray-100 dark:border-dark-700">
            <h2 className="text-xl font-bold dark:text-white">New Food</h2>
            <div className="space-y-3">
                <input 
                    placeholder="Food Name" 
                    value={customFood.name}
                    onChange={(e) => setCustomFood({...customFood, name: e.target.value})}
                    className="w-full p-3 bg-gray-50 dark:bg-dark-700 rounded-lg border border-gray-200 dark:border-dark-600 dark:text-white" 
                />
                <div className="grid grid-cols-2 gap-3">
                    <input type="number" placeholder="Calories" value={customFood.calories} onChange={(e) => setCustomFood({...customFood, calories: e.target.value})} className="p-3 bg-gray-50 dark:bg-dark-700 rounded-lg border border-gray-200 dark:border-dark-600 dark:text-white" />
                    <input type="number" placeholder="Protein (g)" value={customFood.protein} onChange={(e) => setCustomFood({...customFood, protein: e.target.value})} className="p-3 bg-gray-50 dark:bg-dark-700 rounded-lg border border-gray-200 dark:border-dark-600 dark:text-white" />
                    <input type="number" placeholder="Carbs (g)" value={customFood.carbs} onChange={(e) => setCustomFood({...customFood, carbs: e.target.value})} className="p-3 bg-gray-50 dark:bg-dark-700 rounded-lg border border-gray-200 dark:border-dark-600 dark:text-white" />
                    <input type="number" placeholder="Fat (g)" value={customFood.fat} onChange={(e) => setCustomFood({...customFood, fat: e.target.value})} className="p-3 bg-gray-50 dark:bg-dark-700 rounded-lg border border-gray-200 dark:border-dark-600 dark:text-white" />
                </div>
            </div>
            <button 
                onClick={handleCreateCustom}
                className="w-full py-3 bg-primary-600 text-white font-bold rounded-lg hover:bg-primary-700 transition-colors"
            >
                Save to Selection
            </button>
        </div>
      )}
    </div>
  );
};