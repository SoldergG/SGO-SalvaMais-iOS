import React, { useState } from 'react';
import { supabase } from '../services/supabase';
import { Mail, Lock, Loader2, ArrowLeft } from 'lucide-react';

interface AuthProps {
  onSuccess: () => void;
  onBack: () => void;
}

const Auth: React.FC<AuthProps> = ({ onSuccess, onBack }) => {
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSignUp, setIsSignUp] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
        });
        if (error) throw error;
        setMessage('Conta criada! Verifique seu email para confirmar.');
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (error) throw error;
        onSuccess();
      }
    } catch (err: any) {
      setError(err.message || 'Ocorreu um erro na autenticação.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-950 flex flex-col items-center justify-center p-4 transition-colors duration-300">
       <button onClick={onBack} className="absolute top-6 left-6 text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white flex items-center gap-2 transition-colors">
        <ArrowLeft size={18} /> Voltar
      </button>

      <div className="w-full max-w-md bg-white dark:bg-gray-900 p-8 rounded-2xl border border-gray-200 dark:border-gray-800 shadow-xl dark:shadow-2xl">
        <div className="text-center mb-8">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            {isSignUp ? 'Criar Conta' : 'Bem-vindo de volta'}
          </h2>
          <p className="text-gray-500 dark:text-gray-400 text-sm">
            {isSignUp ? 'Comece a transcrever seus áudios hoje.' : 'Acesse seus projetos e transcrições.'}
          </p>
        </div>

        {error && (
          <div className="mb-4 p-3 bg-red-100 dark:bg-red-500/10 border border-red-200 dark:border-red-500/20 text-red-600 dark:text-red-400 text-sm rounded-lg text-center">
            {error}
          </div>
        )}
        
        {message && (
          <div className="mb-4 p-3 bg-emerald-100 dark:bg-emerald-500/10 border border-emerald-200 dark:border-emerald-500/20 text-emerald-600 dark:text-emerald-400 text-sm rounded-lg text-center">
            {message}
          </div>
        )}

        <form onSubmit={handleAuth} className="space-y-4">
          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 uppercase">Email</label>
            <div className="relative">
              <Mail className="absolute left-3 top-3 text-gray-400 dark:text-gray-500" size={18} />
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                className="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 text-gray-900 dark:text-white rounded-lg pl-10 pr-4 py-2.5 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all placeholder-gray-400 dark:placeholder-gray-600"
                placeholder="seu@email.com"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 uppercase">Senha</label>
            <div className="relative">
              <Lock className="absolute left-3 top-3 text-gray-400 dark:text-gray-500" size={18} />
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={6}
                className="w-full bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 text-gray-900 dark:text-white rounded-lg pl-10 pr-4 py-2.5 focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all placeholder-gray-400 dark:placeholder-gray-600"
                placeholder="••••••••"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-semibold rounded-lg transition-all shadow-lg shadow-indigo-500/20 flex items-center justify-center gap-2"
          >
            {loading ? <Loader2 className="animate-spin" size={20} /> : (isSignUp ? 'Criar Conta' : 'Entrar')}
          </button>
        </form>

        <div className="mt-6 text-center">
          <p className="text-gray-500 dark:text-gray-400 text-sm">
            {isSignUp ? 'Já tem uma conta?' : 'Não tem uma conta?'}
            <button
              onClick={() => {
                setIsSignUp(!isSignUp);
                setError(null);
                setMessage(null);
              }}
              className="ml-2 text-indigo-600 dark:text-indigo-400 hover:text-indigo-500 dark:hover:text-indigo-300 font-medium"
            >
              {isSignUp ? 'Entrar' : 'Cadastre-se'}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Auth;