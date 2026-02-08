import React from 'react';
import { PieChart, Pie, Cell, ResponsiveContainer } from 'recharts';

interface MacroRingProps {
  value: number;
  max: number;
  color: string;
  label: string;
  unit: string;
  size?: 'sm' | 'md' | 'lg';
}

export const MacroRing: React.FC<MacroRingProps> = ({ value, max, color, label, unit, size = 'md' }) => {
  const data = [
    { name: 'Completed', value: Math.min(value, max) },
    { name: 'Remaining', value: Math.max(0, max - value) },
  ];

  // Colors: primary (filled), empty (background)
  const COLORS = [color, '#e5e7eb']; // light mode gray-200
  const DARK_COLORS = [color, '#27272a']; // dark mode zinc-700

  // Determine standard radius based on size prop
  let outerRadius = 40;
  let innerRadius = 32;
  let width = 100;

  if (size === 'lg') {
    outerRadius = 70;
    innerRadius = 60;
    width = 160;
  } else if (size === 'sm') {
    outerRadius = 25;
    innerRadius = 20;
    width = 60;
  }

  const isDarkMode = document.documentElement.classList.contains('dark');
  const emptyColor = isDarkMode ? '#3f3f46' : '#e5e7eb';

  return (
    <div className="flex flex-col items-center justify-center">
      <div style={{ width: width, height: width }} className="relative">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              cx="50%"
              cy="50%"
              innerRadius={innerRadius}
              outerRadius={outerRadius}
              startAngle={90}
              endAngle={-270}
              dataKey="value"
              stroke="none"
              cornerRadius={4}
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={index === 0 ? color : emptyColor} />
              ))}
            </Pie>
          </PieChart>
        </ResponsiveContainer>
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          <span className={`font-bold ${size === 'lg' ? 'text-2xl' : 'text-sm'} dark:text-white`}>
            {Math.round(value)}
          </span>
          {size === 'lg' && <span className="text-xs text-gray-500 dark:text-gray-400">of {max}</span>}
        </div>
      </div>
      <div className="mt-1 text-center">
        <p className="text-xs font-semibold text-gray-600 dark:text-gray-300">{label}</p>
        <p className="text-[10px] text-gray-400">{unit}</p>
      </div>
    </div>
  );
};