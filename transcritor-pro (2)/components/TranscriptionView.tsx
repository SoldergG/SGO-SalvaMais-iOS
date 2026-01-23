import React, { useEffect, useRef, useState } from 'react';
import { FileAudio, Download, CheckCircle, Loader2, RefreshCw, User, Clock, Save, Play, CloudUpload, Settings, FileText, Users, Edit2, FileType, Search } from 'lucide-react';
import { AudioChunk, ProcessingStatus, FontFamily, FontSize } from '../types';
import SettingsModal from './SettingsModal';
import { jsPDF } from "jspdf";
import { Document, Packer, Paragraph, TextRun } from "docx";

interface TranscriptionViewProps {
  fileName: string;
  chunks: AudioChunk[];
  status: ProcessingStatus;
  progress: number;
  onDownload: () => void;
  onReset: () => void;
  onRenameSpeaker: (chunkId: number, segmentIndex: number, newName: string) => void;
  onGlobalSpeakerRename: (oldName: string, newName: string) => void;
  onJumpToTime: (timeStr: string) => void;
  onSaveToCloud: () => void;
  isSaving: boolean;
  isDarkMode: boolean;
  toggleTheme: () => void;
  // Customization props
  fontFamily: FontFamily;
  setFontFamily: (font: FontFamily) => void;
  fontSize: FontSize;
  setFontSize: (size: FontSize) => void;
}

// Sub-component for individual speaker input in the global panel
const SpeakerPill: React.FC<{ name: string; onGlobalRename: (old: string, newName: string) => void }> = ({ name, onGlobalRename }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [tempName, setTempName] = useState(name);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    setTempName(name);
  }, [name]);

  useEffect(() => {
    if (isEditing && inputRef.current) {
      inputRef.current.focus();
    }
  }, [isEditing]);

  const handleCommit = () => {
    if (tempName.trim() && tempName !== name) {
      onGlobalRename(name, tempName);
    } else {
      setTempName(name); // Revert if empty or unchanged
    }
    setIsEditing(false);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') handleCommit();
    if (e.key === 'Escape') {
      setTempName(name);
      setIsEditing(false);
    }
  };

  if (isEditing) {
    return (
      <input
        ref={inputRef}
        type="text"
        value={tempName}
        onChange={(e) => setTempName(e.target.value)}
        onBlur={handleCommit}
        onKeyDown={handleKeyDown}
        className="w-32 px-2 py-1 text-xs rounded-lg border border-indigo-500 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 outline-none shadow-sm"
      />
    );
  }

  return (
    <button
      onClick={() => setIsEditing(true)}
      className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 hover:border-indigo-400 dark:hover:border-indigo-500 hover:shadow-md transition-all group"
      title="Clique para renomear este orador em todo o texto"
    >
      <span className="w-2 h-2 rounded-full bg-indigo-500"></span>
      <span className="text-xs font-medium text-gray-700 dark:text-gray-300 max-w-[150px] truncate">{name}</span>
      <Edit2 size={10} className="text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity" />
    </button>
  );
};

// Helper function to highlight text
const HighlightedText = ({ text, highlight }: { text: string, highlight: string }) => {
  if (!highlight.trim()) {
    return <>{text}</>;
  }
  // Escape special regex characters to prevent errors
  const escapedHighlight = highlight.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const parts = text.split(new RegExp(`(${escapedHighlight})`, 'gi'));
  
  return (
    <>
      {parts.map((part, i) => 
        part.toLowerCase() === highlight.toLowerCase() ? (
          <mark key={i} className="bg-yellow-200 dark:bg-yellow-500/30 text-gray-900 dark:text-white rounded-sm px-0.5 font-medium">
            {part}
          </mark>
        ) : (
          part
        )
      )}
    </>
  );
};

// Sub-component for individual segment to handle local edit state
const TranscriptionSegmentItem: React.FC<{
  segment: { speaker: string; timestamp: string; text: string; chunkId: number; index: number };
  onRename: (newName: string) => void;
  onJump: (time: string) => void;
  textSizeClass: string;
  fontFamilyClass: string;
  searchQuery: string;
}> = ({ segment, onRename, onJump, textSizeClass, fontFamilyClass, searchQuery }) => {
  const [speakerName, setSpeakerName] = useState(segment.speaker);
  
  useEffect(() => {
    setSpeakerName(segment.speaker);
  }, [segment.speaker]);

  const hasChanges = speakerName !== segment.speaker;

  const handleSave = () => {
    if (hasChanges) {
      onRename(speakerName);
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSave();
    }
  };

  return (
    <div className="group bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 hover:border-indigo-300 dark:hover:border-gray-700 rounded-xl p-5 transition-all shadow-sm hover:shadow-md">
      <div className="flex flex-col sm:flex-row sm:items-start gap-4 mb-3">
        
        {/* Speaker Input Area */}
        <div className="flex flex-col gap-1 w-full sm:w-64 flex-shrink-0">
           <button 
             onClick={() => onJump(segment.timestamp)}
             className="flex items-center gap-2 text-indigo-600 dark:text-indigo-400 font-mono text-xs bg-indigo-50 dark:bg-indigo-500/10 hover:bg-indigo-100 dark:hover:bg-indigo-500/20 px-2 py-1 rounded w-fit mb-1 cursor-pointer transition-colors group/time"
             title="Ouvir este trecho"
           >
            <Play size={10} className="fill-current" />
            <span className="font-bold">{segment.timestamp}</span>
          </button>
          
          <label className="text-[10px] uppercase tracking-wider text-gray-500 font-bold ml-1">
            Quem fala?
          </label>
          
          <div className="flex items-stretch gap-2">
            <div className="relative flex-1">
              <div className="absolute inset-y-0 left-0 pl-2.5 flex items-center pointer-events-none">
                <User size={14} className="text-gray-400 dark:text-gray-500" />
              </div>
              <input 
                type="text" 
                value={speakerName}
                onChange={(e) => setSpeakerName(e.target.value)}
                onKeyDown={handleKeyDown}
                className={`bg-gray-50 dark:bg-gray-800 border text-gray-900 dark:text-gray-200 text-sm rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 block w-full pl-9 p-2 transition-colors
                  ${hasChanges ? 'border-indigo-500' : 'border-gray-200 dark:border-gray-700'}`}
                placeholder="Nome..."
              />
            </div>
            
            <button
              onClick={handleSave}
              disabled={!hasChanges}
              className={`px-3 rounded-lg flex items-center justify-center transition-all duration-200
                ${hasChanges 
                  ? 'bg-indigo-600 text-white hover:bg-indigo-500 shadow-lg translate-y-0' 
                  : 'bg-gray-200 dark:bg-gray-800 text-gray-400 dark:text-gray-600 opacity-50 cursor-not-allowed'}`}
              title="Salvar nome"
            >
              <Save size={16} />
            </button>
          </div>
        </div>

        {/* Text Content */}
        <div className="flex-1 min-w-0 pt-1">
          <p className={`text-gray-800 dark:text-gray-300 leading-relaxed whitespace-pre-wrap border-l-2 border-transparent pl-0 sm:pl-4 sm:border-gray-100 dark:sm:border-gray-800 ${textSizeClass} ${fontFamilyClass}`}>
            <HighlightedText text={segment.text} highlight={searchQuery} />
          </p>
        </div>
      </div>
    </div>
  );
};

const TranscriptionView: React.FC<TranscriptionViewProps> = ({
  fileName,
  chunks,
  status,
  progress,
  onDownload,
  onReset,
  onRenameSpeaker,
  onGlobalSpeakerRename,
  onJumpToTime,
  onSaveToCloud,
  isSaving,
  isDarkMode,
  toggleTheme,
  fontFamily,
  setFontFamily,
  fontSize,
  setFontSize
}) => {
  const bottomRef = useRef<HTMLDivElement>(null);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [isExportingWord, setIsExportingWord] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  
  const allSegments = chunks.flatMap(c => c.segments.map((s, i) => ({ ...s, chunkId: c.id, index: i })));
  
  // Extract unique speakers
  const uniqueSpeakers = Array.from(new Set(allSegments.map(s => s.speaker))).sort();

  // Filter segments based on search query
  const filteredSegments = allSegments.filter(segment => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return (
      segment.text.toLowerCase().includes(query) ||
      segment.speaker.toLowerCase().includes(query)
    );
  });

  // Auto-scroll to bottom only when new chunks arrive AND user is not searching
  useEffect(() => {
    if (status === ProcessingStatus.TRANSCRIBING && !searchQuery) {
      bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [chunks.length, status, searchQuery]);

  const activeChunkIndex = chunks.findIndex(c => c.status === 'processing');
  const totalChunks = chunks.length;

  const textSizeClass = {
    small: 'text-sm',
    medium: 'text-base',
    large: 'text-lg',
    xlarge: 'text-xl leading-8'
  }[fontSize];

  const fontFamilyClass = {
    inter: 'font-sans',
    lora: 'font-serif',
    mono: 'font-mono',
    oswald: 'font-display tracking-wide'
  }[fontFamily];

  const handleExportPDF = () => {
    const doc = new jsPDF();
    let yPos = 20;
    const pageHeight = doc.internal.pageSize.height;
    const margin = 20;
    const maxLineWidth = doc.internal.pageSize.width - (margin * 2);

    // Title
    doc.setFontSize(16);
    doc.text(`Transcrição: ${fileName}`, margin, yPos);
    yPos += 15;

    // Content
    doc.setFontSize(11);
    
    allSegments.forEach(segment => {
      // Check page break for header (Speaker + Time)
      if (yPos > pageHeight - 20) {
        doc.addPage();
        yPos = 20;
      }

      // Speaker & Timestamp bold
      doc.setFont("helvetica", "bold");
      doc.text(`${segment.speaker} [${segment.timestamp}]`, margin, yPos);
      yPos += 7;

      // Text body normal
      doc.setFont("helvetica", "normal");
      const splitText = doc.splitTextToSize(segment.text, maxLineWidth);
      
      // Check if text fits
      if (yPos + (splitText.length * 7) > pageHeight - margin) {
        doc.addPage();
        yPos = 20;
      }

      doc.text(splitText, margin, yPos);
      yPos += (splitText.length * 7) + 5; // spacing between segments
    });

    doc.save(`transcricao-${fileName}.pdf`);
  };

  const handleExportWord = async () => {
    setIsExportingWord(true);
    try {
      // Create paragraphs from segments
      const children = [
        new Paragraph({
          children: [
            new TextRun({
              text: `Transcrição: ${fileName}`,
              bold: true,
              size: 32, // 16pt
            }),
          ],
          spacing: { after: 400 },
        }),
      ];

      allSegments.forEach(segment => {
        // Speaker Name and Timestamp
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: `${segment.speaker} [${segment.timestamp}]`,
                bold: true,
                size: 24, // 12pt
              }),
            ],
            spacing: { before: 200, after: 100 },
          })
        );

        // Transcription Text
        children.push(
          new Paragraph({
            children: [
              new TextRun({
                text: segment.text,
                size: 24, // 12pt
              }),
            ],
            spacing: { after: 200 },
          })
        );
      });

      const doc = new Document({
        sections: [{
          properties: {},
          children: children,
        }],
      });

      const blob = await Packer.toBlob(doc);
      
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `transcricao-${fileName}.docx`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

    } catch (error) {
      console.error("Error exporting to Word:", error);
      alert("Erro ao exportar para Word. Tente novamente.");
    } finally {
      setIsExportingWord(false);
    }
  };

  return (
    <>
      <div className="flex flex-col w-full px-4 lg:px-6 gap-6 pb-32">
        {/* Header Info - Sticky */}
        <div className="sticky top-20 z-30 flex flex-col xl:flex-row items-start xl:items-center justify-between gap-4 bg-white/90 dark:bg-gray-900/90 p-4 rounded-2xl border border-gray-200 dark:border-gray-800 backdrop-blur-md shadow-lg dark:shadow-2xl">
          <div className="flex items-center gap-4 w-full xl:w-auto overflow-hidden">
            <div className="p-3 bg-indigo-50 dark:bg-indigo-500/20 text-indigo-600 dark:text-indigo-400 rounded-xl flex-shrink-0">
              <FileAudio size={24} />
            </div>
            <div className="min-w-0">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-white truncate" title={fileName}>
                {fileName}
              </h2>
              <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400 whitespace-nowrap">
                {status === ProcessingStatus.TRANSCRIBING && (
                  <span className="flex items-center gap-1 text-indigo-600 dark:text-indigo-400">
                    <Loader2 size={12} className="animate-spin" />
                    Processando parte {activeChunkIndex + 1} de {totalChunks}
                  </span>
                )}
                {status === ProcessingStatus.COMPLETED && (
                  <span className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400">
                    <CheckCircle size={12} />
                    Concluído
                  </span>
                )}
                 {status === ProcessingStatus.ERROR && (
                  <span className="text-red-500 dark:text-red-400">Erro</span>
                )}
              </div>
            </div>
          </div>

          <div className="flex flex-wrap items-center gap-2 w-full xl:w-auto">
             {status !== ProcessingStatus.TRANSCRIBING && (
              <button 
                onClick={onReset}
                className="px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg transition-colors flex items-center gap-2"
                title="Nova Transcrição"
              >
                <RefreshCw size={16} />
                <span className="hidden sm:inline">Novo</span>
              </button>
            )}

            <button 
              onClick={onSaveToCloud}
              disabled={allSegments.length === 0 || isSaving}
              className={`px-3 py-2 text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-all border
                ${allSegments.length === 0
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 border-transparent cursor-not-allowed' 
                  : 'bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 text-indigo-600 dark:text-indigo-300 border-gray-200 dark:border-gray-700'}`}
              title="Salvar no Histórico"
            >
              {isSaving ? <Loader2 size={16} className="animate-spin" /> : <CloudUpload size={16} />}
              <span className="hidden sm:inline">{isSaving ? 'Salvando...' : 'Salvar'}</span>
            </button>
            
            <div className="h-6 w-px bg-gray-200 dark:bg-gray-700 mx-1 hidden md:block"></div>

             <button 
              onClick={handleExportPDF}
              disabled={allSegments.length === 0}
              className={`px-3 py-2 text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-all border
                ${allSegments.length === 0
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 border-transparent cursor-not-allowed' 
                  : 'bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 text-gray-700 dark:text-gray-200 border-gray-200 dark:border-gray-700'}`}
               title="Exportar PDF"
            >
              <FileText size={16} />
              <span className="hidden sm:inline">PDF</span>
            </button>

            <button 
              onClick={handleExportWord}
              disabled={allSegments.length === 0 || isExportingWord}
              className={`px-3 py-2 text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-all border
                ${allSegments.length === 0
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 border-transparent cursor-not-allowed' 
                  : 'bg-white dark:bg-gray-800 hover:bg-gray-50 dark:hover:bg-gray-700 text-blue-600 dark:text-blue-400 border-gray-200 dark:border-gray-700'}`}
               title="Exportar Word"
            >
              {isExportingWord ? <Loader2 size={16} className="animate-spin" /> : <FileType size={16} />}
              <span className="hidden sm:inline">Word</span>
            </button>

            <button 
              onClick={onDownload}
              disabled={allSegments.length === 0}
              className={`px-3 py-2 text-sm font-medium rounded-lg flex items-center justify-center gap-2 transition-all
                ${allSegments.length === 0
                  ? 'bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 cursor-not-allowed' 
                  : 'bg-indigo-600 hover:bg-indigo-500 text-white shadow-lg shadow-indigo-500/20'}`}
            >
              <Download size={16} />
              <span className="hidden sm:inline">TXT</span>
            </button>

            <div className="h-6 w-px bg-gray-200 dark:bg-gray-700 mx-1 hidden md:block"></div>
            
            <button
              onClick={() => setIsSettingsOpen(true)}
              className="p-2 text-gray-500 hover:text-gray-900 dark:text-gray-400 dark:hover:text-white transition-colors"
              title="Definições"
            >
              <Settings size={20} />
            </button>
          </div>
        </div>

        {/* Progress Bar */}
        {(status === ProcessingStatus.TRANSCRIBING || status === ProcessingStatus.ANALYZING) && (
          <div className="sticky top-[152px] z-20 w-full bg-gray-200 dark:bg-gray-800 rounded-full h-1.5 overflow-hidden shadow-md">
            <div 
              className="bg-indigo-500 h-full transition-all duration-500 ease-out"
              style={{ width: `${progress}%` }}
            />
          </div>
        )}

        {/* Main Content Area */}
        <div className="flex flex-col lg:flex-row gap-6 items-start">
          
          {/* Main Transcript Feed */}
          <div className="flex-1 w-full space-y-4">
            
            {/* Search Bar */}
            {allSegments.length > 0 && (
              <div className="relative mb-2 group">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-indigo-500 transition-colors" size={18} />
                <input
                  type="text"
                  placeholder="Buscar na transcrição (texto ou orador)..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-3 bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all shadow-sm text-sm"
                />
              </div>
            )}

             {/* Speaker Management Panel */}
             {uniqueSpeakers.length > 0 && (
              <div className="bg-gray-50 dark:bg-gray-900/50 border border-gray-200 dark:border-gray-800 rounded-xl p-4 mb-2">
                <h3 className="text-xs font-bold text-gray-500 dark:text-gray-400 uppercase tracking-wider mb-3 flex items-center gap-2">
                  <Users size={14} /> 
                  Gerenciar Oradores
                  <span className="normal-case font-normal text-[10px] bg-gray-200 dark:bg-gray-800 px-2 py-0.5 rounded text-gray-500">
                    Renomear aqui altera todos
                  </span>
                </h3>
                <div className="flex flex-wrap gap-2">
                  {uniqueSpeakers.map((speaker, idx) => (
                    <SpeakerPill 
                      key={`${speaker}-${idx}`} 
                      name={speaker} 
                      onGlobalRename={onGlobalSpeakerRename} 
                    />
                  ))}
                </div>
              </div>
            )}

            {allSegments.length === 0 ? (
               <div className="h-64 flex flex-col items-center justify-center text-gray-400 dark:text-gray-600 gap-4 border-2 border-dashed border-gray-200 dark:border-gray-800 rounded-2xl bg-white/50 dark:bg-transparent">
                  <Loader2 size={32} className="animate-spin opacity-50" />
                  <p>Aguardando transcrição...</p>
               </div>
            ) : filteredSegments.length === 0 ? (
               <div className="h-32 flex flex-col items-center justify-center text-gray-500 dark:text-gray-400">
                 <p>Nenhum resultado encontrado para "{searchQuery}"</p>
               </div>
            ) : (
              filteredSegments.map((segment) => (
                <TranscriptionSegmentItem
                  key={`${segment.chunkId}-${segment.index}`}
                  segment={segment}
                  onRename={(newName) => onRenameSpeaker(segment.chunkId, segment.index, newName)}
                  onJump={onJumpToTime}
                  textSizeClass={textSizeClass}
                  fontFamilyClass={fontFamilyClass}
                  searchQuery={searchQuery}
                />
              ))
            )}
            
            <div ref={bottomRef} />
          </div>

          {/* Sidebar Status */}
          <div className="lg:w-64 w-full flex-shrink-0 hidden lg:block sticky top-48">
             <div className="bg-white/50 dark:bg-gray-900/50 rounded-2xl border border-gray-200 dark:border-gray-800 p-4 max-h-[calc(100vh-250px)] overflow-y-auto custom-scrollbar">
                <h3 className="text-xs font-bold text-gray-400 dark:text-gray-500 uppercase tracking-wider mb-4">Chunks de Áudio</h3>
                <div className="space-y-2">
                  {chunks.map((chunk) => (
                    <div 
                      key={chunk.id}
                      className={`flex items-center justify-between p-2 rounded-lg text-xs transition-colors
                        ${chunk.status === 'processing' ? 'bg-indigo-50 dark:bg-indigo-500/10 border border-indigo-200 dark:border-indigo-500/30' : ''}
                        ${chunk.status === 'completed' ? 'text-gray-600 dark:text-gray-400' : 'text-gray-400 dark:text-gray-500'}
                        ${chunk.status === 'error' ? 'bg-red-50 dark:bg-red-500/10 text-red-500 dark:text-red-400' : ''}
                      `}
                    >
                      <div className="flex items-center gap-2">
                        <span className={`w-2 h-2 rounded-full 
                          ${chunk.status === 'completed' ? 'bg-emerald-500' : 
                            chunk.status === 'processing' ? 'bg-indigo-500 animate-pulse' : 
                            chunk.status === 'error' ? 'bg-red-500' : 'bg-gray-300 dark:bg-gray-700'}`} 
                        />
                        <span>Parte {chunk.id + 1}</span>
                      </div>
                      {chunk.status === 'completed' && <CheckCircle size={10} className="text-emerald-500" />}
                      {chunk.status === 'processing' && <Loader2 size={10} className="animate-spin text-indigo-500" />}
                    </div>
                  ))}
                </div>
             </div>
          </div>

        </div>
      </div>

      <SettingsModal 
        isOpen={isSettingsOpen} 
        onClose={() => setIsSettingsOpen(false)}
        isDarkMode={isDarkMode}
        toggleTheme={toggleTheme}
        fontSize={fontSize}
        setFontSize={setFontSize}
        fontFamily={fontFamily}
        setFontFamily={setFontFamily}
      />
    </>
  );
};

export default TranscriptionView;
