import React, { useState, useCallback, useEffect, useRef, useMemo } from 'react';
import FileUpload from './components/FileUpload';
import TranscriptionView from './components/TranscriptionView';
import LandingPage from './components/LandingPage';
import Auth from './components/Auth';
import AudioPlayer from './components/AudioPlayer';
import AdminDashboard from './components/AdminDashboard';
import { generateAudioChunksMetadata, readChunkData, downloadText, getBlobDuration, parseTimeStringToSeconds, formatTime } from './services/audioUtils';
import { transcribeAudioChunk } from './services/geminiService';
import { AudioChunk, ProcessingStatus, UserProfile, FontFamily, FontSize } from './types';
import { Mic, LogOut, ShieldCheck, Loader2, Lock, Wrench, Clock, RefreshCw } from 'lucide-react';
import { supabase } from './services/supabase';

const App: React.FC = () => {
  const [view, setView] = useState<'landing' | 'auth' | 'app' | 'pending_approval' | 'loading'>('landing');
  const [session, setSession] = useState<any>(null);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [isAdminPanelOpen, setIsAdminPanelOpen] = useState(false);

  const [status, setStatus] = useState<ProcessingStatus>(ProcessingStatus.IDLE);
  const [fileName, setFileName] = useState<string>('');
  const [fileSize, setFileSize] = useState<number>(0);
  const [totalDuration, setTotalDuration] = useState<number>(0);
  const [chunks, setChunks] = useState<AudioChunk[]>([]);
  const [sourceFile, setSourceFile] = useState<File | null>(null); 
  const [currentChunkIndex, setCurrentChunkIndex] = useState<number>(-1);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [audioUrl, setAudioUrl] = useState<string | null>(null);
  const audioRef = useRef<HTMLAudioElement>(null);
  const [isDarkMode, setIsDarkMode] = useState<boolean>(true);
  const [isFixingProfile, setIsFixingProfile] = useState(false);
  const [isCheckingStatus, setIsCheckingStatus] = useState(false);

  // Customization State
  const [fontFamily, setFontFamily] = useState<FontFamily>('inter');
  const [fontSize, setFontSize] = useState<FontSize>('medium');

  useEffect(() => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme === 'dark') setIsDarkMode(true);
    else if (savedTheme === 'light') setIsDarkMode(false);
    else setIsDarkMode(true);
  }, []);

  useEffect(() => {
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
  }, [isDarkMode]);

  const toggleTheme = () => setIsDarkMode(prev => !prev);

  // Manual Profile Creation (Self-Healing)
  const createProfileManually = async () => {
    if (!session?.user) return;
    setIsFixingProfile(true);
    try {
      // Direct insert attempt - requires "Users can insert own profile" policy
      const { error } = await supabase.from('profiles').insert({
        id: session.user.id,
        email: session.user.email,
        role: 'free',
        is_approved: false
      });

      if (error) throw error;
      
      alert("Perfil corrigido com sucesso! Recarregando...");
      window.location.reload();
    } catch (err: any) {
      console.error("Manual fix failed:", err);
      alert("Falha ao criar perfil: " + err.message + "\nPor favor, execute o script 'supabase_fix_final.sql' no Supabase.");
    } finally {
      setIsFixingProfile(false);
    }
  };

  // Fetch Profile Data with Retry Logic
  const fetchProfile = async (userId: string, retries = 3) => {
    try {
      // Use maybeSingle() instead of single() to avoid PGRST116 error if row is missing
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();
      
      if (error) throw error;
      
      // If profile doesn't exist yet (race condition or old user)
      if (!data) {
        if (retries > 0) {
          console.log(`Perfil não encontrado, tentando novamente... (${retries} restantes)`);
          // Wait 1 second and try again
          setTimeout(() => fetchProfile(userId, retries - 1), 1000);
          return;
        }

        // Only show error if retries exhausted
        console.warn("Profile missing for user:", userId);
        setErrorMsg("PROFILE_MISSING"); // Special code to show fix button
        return;
      }
      
      const profile = data as UserProfile;
      setUserProfile(profile);

      // Clear any previous generic errors
      setErrorMsg(null);

      // Routing logic based on approval status
      if (!profile.is_approved) {
        setView('pending_approval');
      } else {
        setView('app');
      }
    } catch (error: any) {
      console.error("Error fetching profile:", error);
      if (error?.code === '42P17') {
         alert("ERRO DE CONFIGURAÇÃO: Recursão infinita detectada no banco de dados. Por favor, execute o arquivo 'supabase_fix.sql' no Editor SQL do Supabase.");
      } else {
         setErrorMsg("Erro ao carregar perfil: " + (error.message || "Erro desconhecido"));
      }
    }
  };

  // Poll for approval status when in pending_approval view
  useEffect(() => {
    let intervalId: any;
    
    if (view === 'pending_approval' && session?.user?.id) {
      intervalId = setInterval(async () => {
        setIsCheckingStatus(true);
        const { data } = await supabase
          .from('profiles')
          .select('is_approved')
          .eq('id', session.user.id)
          .maybeSingle();
          
        if (data && data.is_approved) {
          // If approved, refresh full profile to enter app
          fetchProfile(session.user.id);
        }
        setTimeout(() => setIsCheckingStatus(false), 500);
      }, 5000); // Check every 5 seconds
    }

    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, [view, session]);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      if (session) {
        fetchProfile(session.user.id);
      }
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      if (session) {
        // If we have a session, assume we are checking profile, don't show landing immediately
        if (view === 'landing') setView('loading'); 
        fetchProfile(session.user.id);
      } else {
        setView('landing');
        setUserProfile(null);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
    handleReset();
    setView('landing');
    setUserProfile(null);
  };

  const progress = chunks.length > 0 
    ? ((chunks.filter(c => c.status === 'completed').length) / chunks.length) * 100 
    : 0;

  const allSegments = useMemo(() => {
    return chunks.flatMap(c => c.segments);
  }, [chunks]);

  const handleFileSelect = useCallback(async (file: File) => {
    try {
      // Check usage limits here if needed using userProfile.usage_count vs max_usage_limit
      if (userProfile && userProfile.usage_count >= userProfile.max_usage_limit) {
        setErrorMsg("Limite de uso atingido. Contate o administrador.");
        setStatus(ProcessingStatus.ERROR);
        return;
      }

      setStatus(ProcessingStatus.ANALYZING);
      setFileName(file.name);
      setFileSize(file.size);
      setErrorMsg(null);
      setSourceFile(file); 
      
      const duration = await getBlobDuration(file);
      setTotalDuration(duration);
      
      const url = URL.createObjectURL(file);
      setAudioUrl(url);

      const newChunks = await generateAudioChunksMetadata(file);
      
      setChunks(newChunks);
      setCurrentChunkIndex(0);
      setStatus(ProcessingStatus.TRANSCRIBING);
    } catch (e) {
      console.error(e);
      setErrorMsg("Erro ao preparar o áudio. Tente um arquivo diferente.");
      setStatus(ProcessingStatus.ERROR);
    }
  }, [userProfile]);

  const processChunk = useCallback(async (index: number) => {
    if (index < 0 || index >= chunks.length) {
      if (index >= chunks.length && chunks.length > 0) {
        setStatus(ProcessingStatus.COMPLETED);
        // Increment usage count in DB
        if (session?.user?.id) {
           await supabase.rpc('increment_usage', { user_id: session.user.id, amount: 1 });
        }
      }
      return;
    }

    if (!sourceFile) {
        setErrorMsg("Arquivo de origem perdido. Por favor, recarregue.");
        setStatus(ProcessingStatus.ERROR);
        return;
    }

    const chunk = chunks[index];
    setChunks(prev => prev.map(c => c.id === chunk.id ? { ...c, status: 'processing' } : c));

    try {
      const base64Data = await readChunkData(sourceFile, chunk.startByte, chunk.endByte);
      const previousChunk = index > 0 ? chunks[index - 1] : null;
      const context = previousChunk?.segments.map(s => s.text).join(' ').slice(-500) || '';
      const previousSegments = chunks.slice(0, index).flatMap(c => c.segments);
      const knownSpeakers = Array.from(new Set(previousSegments.map(s => s.speaker))).sort();

      const segments = await transcribeAudioChunk(
        base64Data, 
        chunk.mimeType || 'audio/mp3',
        context,
        knownSpeakers 
      );
      
      const adjustedSegments = segments.map(seg => {
        const segRelativeSeconds = parseTimeStringToSeconds(seg.timestamp);
        const absoluteSeconds = (chunk.startTimeOffset || 0) + segRelativeSeconds;
        return {
          ...seg,
          originalTimestamp: seg.timestamp,
          timestamp: formatTime(absoluteSeconds)
        };
      });

      setChunks(prev => prev.map(c => c.id === chunk.id ? { 
        ...c, 
        status: 'completed', 
        segments: adjustedSegments
      } : c));
      
      setCurrentChunkIndex(index + 1);

    } catch (err) {
      console.error(`Error processing chunk ${chunk.id}`, err);
      const msg = err instanceof Error ? err.message : "Falha desconhecida";
      setChunks(prev => prev.map(c => c.id === chunk.id ? { ...c, status: 'error', error: msg } : c));
      setCurrentChunkIndex(index + 1);
    }
  }, [chunks, sourceFile, session]);

  useEffect(() => {
    if (status === ProcessingStatus.TRANSCRIBING && currentChunkIndex >= 0 && currentChunkIndex < chunks.length) {
      const timer = setTimeout(() => {
        const currentChunk = chunks[currentChunkIndex];
        if (currentChunk && currentChunk.status === 'pending') {
          processChunk(currentChunkIndex);
        }
      }, 500); 
      return () => clearTimeout(timer);
    } else if (status === ProcessingStatus.TRANSCRIBING && currentChunkIndex >= chunks.length && chunks.length > 0) {
        setStatus(ProcessingStatus.COMPLETED);
    }
  }, [currentChunkIndex, status, chunks, processChunk]);

  const handleSpeakerRename = (chunkId: number, segmentIndex: number, newName: string) => {
    setChunks(prev => prev.map(chunk => {
      if (chunk.id === chunkId) {
        const newSegments = [...chunk.segments];
        newSegments[segmentIndex] = { ...newSegments[segmentIndex], speaker: newName };
        return { ...chunk, segments: newSegments };
      }
      return chunk;
    }));
  };

  const handleGlobalSpeakerRename = (oldName: string, newName: string) => {
    if (!newName.trim() || oldName === newName) return;
    setChunks(prev => prev.map(chunk => ({
      ...chunk,
      segments: chunk.segments.map(seg => ({
        ...seg,
        speaker: seg.speaker === oldName ? newName : seg.speaker
      }))
    })));
  };

  const handleReset = () => {
    setStatus(ProcessingStatus.IDLE);
    setFileName('');
    setFileSize(0);
    setTotalDuration(0);
    setChunks([]);
    setSourceFile(null); 
    setCurrentChunkIndex(-1);
    setErrorMsg(null);
    setIsSaving(false);
    if (audioUrl) {
      URL.revokeObjectURL(audioUrl);
      setAudioUrl(null);
    }
  };

  const handleDownload = () => {
    const fullText = chunks
      .flatMap(c => c.segments)
      .map(s => `[${s.timestamp}] ${s.speaker}:\n${s.text}\n`)
      .join('\n');
    downloadText(`transcricao-${fileName}.txt`, fullText);
  };

  const handleSaveToCloud = async () => {
    if (!session?.user) return alert("Você precisa estar logado para salvar.");
    setIsSaving(true);
    try {
      const allSegments = chunks.flatMap(c => c.segments);
      const { error } = await supabase.from('transcriptions').insert({
        user_id: session.user.id,
        file_name: fileName,
        segments: allSegments,
        duration: totalDuration
      });
      if (error) throw error;
      alert("Transcrição salva com sucesso!");
    } catch (err: any) {
      alert("Erro ao salvar: " + err.message);
    } finally {
      setIsSaving(false);
    }
  };

  const handleJumpToTime = (timeStr: string) => {
    const seconds = parseTimeStringToSeconds(timeStr);
    if (audioRef.current) {
      audioRef.current.currentTime = seconds;
      audioRef.current.play();
    }
  };

  // VIEWS RENDER LOGIC

  if (view === 'loading') {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-950 flex flex-col items-center justify-center">
        <Loader2 className="animate-spin text-indigo-600 dark:text-indigo-400" size={48} />
        <p className="mt-4 text-gray-500 font-medium">Carregando perfil...</p>
      </div>
    );
  }

  if (view === 'landing') return <LandingPage onGetStarted={() => setView('auth')} onLogin={() => setView('auth')} />;
  
  if (view === 'auth') return (
    <Auth 
      onSuccess={() => {
        // We let the auth state change listener handle the view transition to ensure profile check is done.
        // Just set to loading in the meantime
        setView('loading');
      }} 
      onBack={() => setView('landing')} 
    />
  );

  if (view === 'pending_approval') {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-950 flex flex-col items-center justify-center p-6 text-center animate-fade-in">
        <div className="bg-white dark:bg-gray-900 p-8 rounded-2xl shadow-xl max-w-md w-full border border-gray-200 dark:border-gray-800 relative overflow-hidden">
          <div className="absolute top-0 left-0 w-full h-1 bg-yellow-500"></div>
          <div className="w-20 h-20 bg-yellow-50 dark:bg-yellow-900/20 text-yellow-600 dark:text-yellow-500 rounded-full flex items-center justify-center mx-auto mb-6 shadow-sm">
            <Clock size={40} />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-3">À espera de aprovação</h2>
          <p className="text-gray-500 dark:text-gray-400 mb-8 leading-relaxed text-sm">
            A sua conta foi criada com sucesso! <br/>
            Para garantir a qualidade do serviço, um administrador precisa ativar o seu acesso.
          </p>
          
          <div className="space-y-3">
             <button 
               onClick={() => fetchProfile(session?.user?.id)} 
               disabled={isCheckingStatus}
               className="w-full py-3 bg-indigo-600 hover:bg-indigo-500 text-white font-medium rounded-xl transition-all shadow-lg shadow-indigo-500/20 flex items-center justify-center gap-2"
             >
               {isCheckingStatus ? <Loader2 size={18} className="animate-spin" /> : <RefreshCw size={18} />}
               {isCheckingStatus ? 'Verificando...' : 'Verificar Status Agora'}
             </button>
             
             <button 
               onClick={handleLogout} 
               className="w-full py-3 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 text-gray-700 dark:text-gray-300 font-medium rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
             >
               Sair da conta
             </button>
          </div>
          
          <div className="mt-6 pt-6 border-t border-gray-100 dark:border-gray-800 text-xs text-gray-400 flex justify-between items-center">
             <span>Status: <span className="text-yellow-500 font-semibold">Pendente</span></span>
             <span className="font-mono">{session?.user?.id.slice(0,8)}...</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`min-h-screen bg-gray-50 dark:bg-gray-950 text-gray-900 dark:text-gray-100 flex flex-col transition-colors duration-300 font-${fontFamily}`}>
      <header className="border-b border-gray-200 dark:border-gray-800 bg-white/90 dark:bg-gray-900/50 backdrop-blur-md sticky top-0 z-50 transition-colors">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2 text-indigo-600 dark:text-indigo-400">
            <div className="p-2 bg-indigo-50 dark:bg-indigo-500/10 rounded-lg"><Mic size={20} /></div>
            <h1 className="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-indigo-600 to-purple-600 dark:from-indigo-400 dark:to-purple-400">Transcritor Pro</h1>
          </div>
          <div className="flex items-center gap-4">
            {/* ADMIN BUTTON */}
            {userProfile && (userProfile.role === 'admin' || userProfile.role === 'super_admin') && (
              <button 
                onClick={() => setIsAdminPanelOpen(true)}
                className="flex items-center gap-2 px-3 py-1.5 bg-indigo-100 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 rounded-lg text-sm font-medium hover:bg-indigo-200 dark:hover:bg-indigo-900/50 transition-colors"
              >
                <ShieldCheck size={16} />
                <span className="hidden sm:inline">{userProfile.role === 'super_admin' ? 'Admin+' : 'Admin'}</span>
              </button>
            )}
            
            <div className="text-sm text-gray-500 hidden sm:block flex flex-col items-end leading-tight">
               <span>{session?.user?.email}</span>
               {userProfile && <span className="text-[10px] uppercase font-bold tracking-wider opacity-60">{userProfile.role === 'super_admin' ? 'Admin+' : userProfile.role}</span>}
            </div>
            <button onClick={handleLogout} className="p-2 text-gray-500 hover:text-gray-900 dark:hover:text-white transition-colors"><LogOut size={20} /></button>
          </div>
        </div>
      </header>

      <main className="flex-1 flex flex-col w-full max-w-7xl mx-auto">
        {errorMsg && (
          <div className="w-full max-w-2xl mx-auto mt-6 p-6 bg-red-50 dark:bg-red-900/10 border border-red-100 dark:border-red-900/30 rounded-2xl text-center">
            {errorMsg === "PROFILE_MISSING" ? (
              <div className="flex flex-col items-center gap-4">
                 <div className="bg-red-100 dark:bg-red-900/20 p-3 rounded-full text-red-600 dark:text-red-400">
                   <Wrench size={32} />
                 </div>
                 <div>
                    <h3 className="text-lg font-bold text-red-700 dark:text-red-400 mb-1">Perfil Não Encontrado</h3>
                    <p className="text-sm text-red-600/80 dark:text-red-400/80">
                      Ocorreu um erro na criação automática do seu perfil no banco de dados. 
                      Isso pode acontecer devido a caracteres maiúsculos no email ou falhas temporárias.
                    </p>
                 </div>
                 <button 
                  onClick={createProfileManually}
                  disabled={isFixingProfile}
                  className="px-6 py-2.5 bg-indigo-600 hover:bg-indigo-500 text-white rounded-lg font-medium shadow-lg shadow-indigo-500/25 transition-all flex items-center gap-2"
                >
                  {isFixingProfile ? <Loader2 size={18} className="animate-spin" /> : <Wrench size={18} />}
                  Auto-Corrigir Agora
                </button>
              </div>
            ) : (
              <>
                <p className="text-red-600 dark:text-red-400 mb-2">{errorMsg}</p>
                <button onClick={handleReset} className="text-sm font-medium underline hover:text-red-700 dark:hover:text-red-300">Tentar novamente</button>
              </>
            )}
          </div>
        )}

        {status === ProcessingStatus.IDLE ? (
          <div className="flex-1 flex flex-col justify-center animate-fade-in p-4">
            <div className="text-center mb-8">
              <h2 className={`text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-4 tracking-tight font-${fontFamily}`}>
                Sua área de trabalho IA. <br/>
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-purple-600 dark:from-indigo-400 dark:to-purple-500">
                  Transcrição Profissional.
                </span>
              </h2>
              <p className="text-gray-500 dark:text-gray-400 text-lg max-w-2xl mx-auto px-4">
                Selecione seu arquivo de áudio. Suporte a diarização, exportação multi-formato e alta precisão.
              </p>
            </div>
            <FileUpload onFileSelect={handleFileSelect} />
          </div>
        ) : (
          <div className="flex-1 py-4 md:py-8 animate-fade-in w-full">
            <TranscriptionView
              fileName={fileName}
              chunks={chunks}
              status={status}
              progress={progress}
              onDownload={handleDownload}
              onReset={handleReset}
              onRenameSpeaker={handleSpeakerRename}
              onGlobalSpeakerRename={handleGlobalSpeakerRename}
              onJumpToTime={handleJumpToTime}
              onSaveToCloud={handleSaveToCloud}
              isSaving={isSaving}
              isDarkMode={isDarkMode}
              toggleTheme={toggleTheme}
              fontFamily={fontFamily}
              setFontFamily={setFontFamily}
              fontSize={fontSize}
              setFontSize={setFontSize}
            />
          </div>
        )}
      </main>
      
      {isAdminPanelOpen && userProfile && (
        <AdminDashboard currentUser={userProfile} onClose={() => setIsAdminPanelOpen(false)} />
      )}

      <AudioPlayer src={audioUrl} ref={audioRef} segments={allSegments} />
    </div>
  );
};

export default App;