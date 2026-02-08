import React from 'react';
import { Home, List, PlusCircle, BarChart2, Settings } from 'lucide-react';
import { AppTab } from '../types';

interface LayoutProps {
  children: React.ReactNode;
  activeTab: AppTab;
  onTabChange: (tab: AppTab) => void;
}

export const Layout: React.FC<LayoutProps> = ({ children, activeTab, onTabChange }) => {
  const navItems = [
    { id: AppTab.DASHBOARD, icon: Home, label: 'Home' },
    { id: AppTab.FOOD_LOG, icon: List, label: 'Log' },
    { id: AppTab.ADD_SCAN, icon: PlusCircle, label: 'Add' },
    { id: AppTab.PROGRESS, icon: BarChart2, label: 'Progress' },
    { id: AppTab.SETTINGS, icon: Settings, label: 'Settings' },
  ];

  return (
    <div className="flex flex-col h-screen w-full bg-gray-50 dark:bg-dark-900 transition-colors duration-300 overflow-hidden">
      {/* Main Content Area - Adds padding for top status bar (notch) */}
      <main className="flex-1 overflow-y-auto no-scrollbar pb-24 pt-[env(safe-area-inset-top)] px-[env(safe-area-inset-left)] pr-[env(safe-area-inset-right)]">
        {children}
      </main>

      {/* Bottom Navigation - Adds padding for bottom home indicator */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white dark:bg-dark-800 border-t border-gray-200 dark:border-dark-700 pb-[env(safe-area-inset-bottom)] z-50">
        <div className="flex justify-around items-center h-16">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => onTabChange(item.id)}
                className={`flex flex-col items-center justify-center w-full h-full space-y-1 transition-all duration-200 select-none active:scale-95 ${
                  isActive
                    ? 'text-primary-600 dark:text-primary-500'
                    : 'text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300'
                }`}
              >
                <Icon size={isActive ? 24 : 22} strokeWidth={isActive ? 2.5 : 2} />
                <span className="text-[10px] font-medium">{item.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
};