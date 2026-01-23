import React from 'react';
import { X, Moon, Sun, Type, Monitor, CaseSensitive } from 'lucide-react';
import { FontFamily, FontSize } from '../types';

interface SettingsModalProps {
  isOpen: boolean;
  onClose: () => void;
  isDarkMode: boolean;
  toggleTheme: () => void;
  fontSize: FontSize;
  setFontSize: (size: FontSize) => void;
  fontFamily: FontFamily;
  setFontFamily: (font: FontFamily) => void;
}

const SettingsModal: React.FC<SettingsModalProps> = ({ 
  isOpen, 
  onClose, 
  isDarkMode, 
  toggleTheme,
  fontSize,
  setFontSize,
  fontFamily,
  setFontFamily
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm animate-fade-in">
      <div className="bg-white dark:bg-gray-900 rounded-2xl w-full max-w-lg shadow-2xl border border-gray-200 dark:border-gray-800 overflow-hidden">
        
        {/* Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-100 dark:border-gray-800">
          <h2 className="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
            <Monitor size={18} />
            Personalização
          </h2>
          <button 
            onClick={onClose}
            className="p-1 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-500 transition-colors"
          >
            <X size={20} />
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-8">
          
          {/* Theme Section */}
          <div>
            <label className="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3">
              Tema
            </label>
            <div className="flex bg-gray-100 dark:bg-gray-800 p-1 rounded-xl">
              <button
                onClick={() => isDarkMode && toggleTheme()}
                className={`flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-sm font-medium transition-all ${
                  !isDarkMode 
                    ? 'bg-white text-indigo-600 shadow-sm' 
                    : 'text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white'
                }`}
              >
                <Sun size={16} />
                Claro
              </button>
              <button
                onClick={() => !isDarkMode && toggleTheme()}
                className={`flex-1 flex items-center justify-center gap-2 py-2 rounded-lg text-sm font-medium transition-all ${
                  isDarkMode 
                    ? 'bg-gray-700 text-white shadow-sm' 
                    : 'text-gray-500 hover:text-gray-900'
                }`}
              >
                <Moon size={16} />
                Escuro
              </button>
            </div>
          </div>

          {/* Typography Section */}
          <div>
            <label className="block text-xs font-semibold text-gray-400 uppercase tracking-wider mb-3 flex items-center gap-2">
              <Type size={14} /> Tipografia
            </label>
            
            {/* Font Family */}
            <div className="grid grid-cols-2 gap-3 mb-4">
              <button
                onClick={() => setFontFamily('inter')}
                className={`p-3 border rounded-xl text-left transition-all ${
                  fontFamily === 'inter' 
                  ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400' 
                  : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                }`}
              >
                <span className="block text-sm font-bold font-sans">Inter (Padrão)</span>
                <span className="text-xs opacity-70 font-sans">Moderno e limpo</span>
              </button>
              
              <button
                onClick={() => setFontFamily('lora')}
                className={`p-3 border rounded-xl text-left transition-all ${
                  fontFamily === 'lora' 
                  ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400' 
                  : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                }`}
              >
                <span className="block text-sm font-bold font-serif">Lora (Serif)</span>
                <span className="text-xs opacity-70 font-serif">Elegante para leitura</span>
              </button>

              <button
                onClick={() => setFontFamily('mono')}
                className={`p-3 border rounded-xl text-left transition-all ${
                  fontFamily === 'mono' 
                  ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400' 
                  : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                }`}
              >
                <span className="block text-sm font-bold font-mono">Mono</span>
                <span className="text-xs opacity-70 font-mono">Técnico e preciso</span>
              </button>

              <button
                onClick={() => setFontFamily('oswald')}
                className={`p-3 border rounded-xl text-left transition-all ${
                  fontFamily === 'oswald' 
                  ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400' 
                  : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800'
                }`}
              >
                <span className="block text-sm font-bold font-display uppercase">Oswald</span>
                <span className="text-xs opacity-70 font-display">Impactante</span>
              </button>
            </div>

            {/* Font Size */}
            <div className="flex gap-2">
              {(['small', 'medium', 'large', 'xlarge'] as FontSize[]).map((size) => (
                <button
                  key={size}
                  onClick={() => setFontSize(size)}
                  className={`flex-1 py-2 px-1 border rounded-lg flex items-center justify-center transition-all ${
                    fontSize === size
                      ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-900/20 text-indigo-600 dark:text-indigo-400'
                      : 'border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400'
                  }`}
                >
                  <CaseSensitive size={size === 'small' ? 14 : size === 'medium' ? 18 : size === 'large' ? 22 : 26} />
                </button>
              ))}
            </div>
            <div className="flex justify-between text-[10px] text-gray-400 mt-1 px-2 uppercase font-bold">
              <span>Pequeno</span>
              <span>Extra Grande</span>
            </div>
          </div>

        </div>

        {/* Footer */}
        <div className="p-4 bg-gray-50 dark:bg-gray-800/50 text-center border-t border-gray-100 dark:border-gray-800">
          <p className="text-xs text-gray-400">Transcritor Pro v2.0</p>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
