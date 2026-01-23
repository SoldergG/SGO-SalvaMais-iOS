import React from 'react';
import { Mic, Zap, Clock, Shield, ChevronRight } from 'lucide-react';

interface LandingPageProps {
  onGetStarted: () => void;
  onLogin: () => void;
}

const LandingPage: React.FC<LandingPageProps> = ({ onGetStarted, onLogin }) => {
  return (
    <div className="flex flex-col min-h-screen bg-white dark:bg-gray-950 text-gray-900 dark:text-white transition-colors duration-300">
      {/* Hero Section */}
      <nav className="flex items-center justify-between px-6 py-6 max-w-7xl mx-auto w-full">
        <div className="flex items-center gap-2 text-indigo-600 dark:text-indigo-400">
          <div className="p-2 bg-indigo-50 dark:bg-indigo-500/10 rounded-lg">
            <Mic size={24} />
          </div>
          <span className="text-xl font-bold">Transcritor Pro</span>
        </div>
        <button 
          onClick={onLogin}
          className="text-sm font-medium text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
        >
          Entrar na conta
        </button>
      </nav>

      <main className="flex-1 flex flex-col items-center justify-center px-4 text-center mt-10 md:mt-20 mb-20">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-50 dark:bg-indigo-500/10 text-indigo-600 dark:text-indigo-400 text-xs font-medium mb-6 border border-indigo-100 dark:border-indigo-500/20">
          <Zap size={12} />
          <span>Powered by Gemini 2.0 Flash</span>
        </div>
        
        <h1 className="text-5xl md:text-7xl font-bold tracking-tight mb-6 max-w-4xl bg-clip-text text-transparent bg-gradient-to-b from-gray-900 to-gray-500 dark:from-white dark:to-gray-400">
          Transforme áudio em texto <br/> com IA de ponta.
        </h1>
        
        <p className="text-lg md:text-xl text-gray-600 dark:text-gray-400 max-w-2xl mb-10 leading-relaxed">
          Transcreva reuniões, podcasts e aulas ilimitadamente. <br/>
          Rápido, preciso e com identificação de oradores via Gemini API.
        </p>

        <button 
          onClick={onGetStarted}
          className="group relative px-8 py-4 bg-indigo-600 hover:bg-indigo-500 text-white rounded-full text-lg font-semibold transition-all shadow-lg shadow-indigo-500/25 flex items-center gap-2"
        >
          Começar Agora Gratuitamente
          <ChevronRight className="group-hover:translate-x-1 transition-transform" />
        </button>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-24 max-w-6xl w-full px-4 text-left">
          <div className="p-6 rounded-2xl bg-white dark:bg-gray-900/50 border border-gray-200 dark:border-gray-800 hover:border-indigo-300 dark:hover:border-indigo-500/30 transition-colors shadow-sm">
            <div className="w-12 h-12 bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center text-indigo-600 dark:text-indigo-400 mb-4">
              <Clock size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Processamento Rápido</h3>
            <p className="text-gray-600 dark:text-gray-400">O modelo Gemini Flash processa horas de áudio em segundos, muito mais rápido que modelos locais.</p>
          </div>

          <div className="p-6 rounded-2xl bg-white dark:bg-gray-900/50 border border-gray-200 dark:border-gray-800 hover:border-indigo-300 dark:hover:border-indigo-500/30 transition-colors shadow-sm">
            <div className="w-12 h-12 bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center text-indigo-600 dark:text-indigo-400 mb-4">
              <Shield size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Seguro e Privado</h3>
            <p className="text-gray-600 dark:text-gray-400">Seus dados são enviados diretamente para a API do Google para processamento e não são armazenados por nós.</p>
          </div>

          <div className="p-6 rounded-2xl bg-white dark:bg-gray-900/50 border border-gray-200 dark:border-gray-800 hover:border-indigo-300 dark:hover:border-indigo-500/30 transition-colors shadow-sm">
            <div className="w-12 h-12 bg-gray-100 dark:bg-gray-800 rounded-lg flex items-center justify-center text-indigo-600 dark:text-indigo-400 mb-4">
              <Mic size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Qualidade Superior</h3>
            <p className="text-gray-600 dark:text-gray-400">O Gemini 2.0 Flash entende nuances, múltiplos idiomas e formata o texto automaticamente.</p>
          </div>
        </div>
      </main>

      <footer className="border-t border-gray-200 dark:border-gray-900 py-8 text-center text-gray-500 dark:text-gray-600">
        <p>&copy; 2024 Transcritor Pro. Todos os direitos reservados.</p>
      </footer>
    </div>
  );
};

export default LandingPage;