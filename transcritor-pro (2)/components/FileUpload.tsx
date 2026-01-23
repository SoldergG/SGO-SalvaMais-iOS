import React, { useRef, useState } from 'react';
import { Upload, Music, AlertCircle, CloudLightning, FileWarning } from 'lucide-react';

interface FileUploadProps {
  onFileSelect: (file: File) => void;
}

const FileUpload: React.FC<FileUploadProps> = ({ onFileSelect }) => {
  const [isDragging, setIsDragging] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Security: Max file size (2GB) to prevent browser crash, though chunks handle most cases.
  const MAX_FILE_SIZE = 2 * 1024 * 1024 * 1024; 

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      validateAndPassFile(e.dataTransfer.files[0]);
    }
  };

  const handleFileInput = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files.length > 0) {
      validateAndPassFile(e.target.files[0]);
    }
  };

  const validateAndPassFile = (file: File) => {
    setError(null);

    // 1. Security Check: MIME Type validation
    const validTypes = [
        'audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 
        'audio/ogg', 'audio/m4a', 'audio/x-m4a', 'audio/mp4', 'audio/aac',
        'video/mp4', 'video/mpeg', 'video/webm'
    ];
    
    // Some browsers have loose mime types, so we also check extension as fallback
    const validExtensions = ['.mp3', '.wav', '.ogg', '.m4a', '.mp4', '.aac', '.webm'];
    const hasValidExtension = validExtensions.some(ext => file.name.toLowerCase().endsWith(ext));

    if (!file.type.startsWith('audio/') && !file.type.startsWith('video/') && !hasValidExtension) {
      setError('Formato de arquivo não suportado ou inseguro.');
      return;
    }

    // 2. Security/Stability Check: File Size
    if (file.size > MAX_FILE_SIZE) {
        setError('O arquivo excede o limite de segurança do navegador (2GB).');
        return;
    }

    onFileSelect(file);
  };

  return (
    <div className="w-full max-w-2xl mx-auto mt-10 p-6">
      <div
        className={`relative border-2 border-dashed rounded-2xl p-12 transition-all duration-300 ease-in-out flex flex-col items-center justify-center text-center cursor-pointer group
          ${isDragging 
            ? 'border-indigo-500 bg-indigo-50 dark:bg-indigo-500/10' 
            : 'border-gray-300 dark:border-gray-700 hover:border-indigo-400 hover:bg-gray-100 dark:hover:bg-gray-800/50 bg-white dark:bg-gray-900/50'
          }`}
        onDragOver={handleDragOver}
        onDragLeave={handleDragLeave}
        onDrop={handleDrop}
        onClick={() => fileInputRef.current?.click()}
      >
        <input
          type="file"
          ref={fileInputRef}
          onChange={handleFileInput}
          className="hidden"
          accept="audio/*,video/*"
        />
        
        <div className={`p-4 rounded-full mb-4 transition-colors ${isDragging ? 'bg-indigo-500 text-white' : 'bg-gray-100 dark:bg-gray-800 text-indigo-500 dark:text-indigo-400 group-hover:bg-indigo-500 group-hover:text-white'}`}>
          <Upload size={32} />
        </div>

        <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
          Arraste seu áudio aqui ou clique para selecionar
        </h3>
        <p className="text-gray-500 dark:text-gray-400 text-sm max-w-md">
          Suporta MP3, WAV, M4A, OGG, MP4. <br/>
          O processamento ocorre em pedaços para segurança da memória.
        </p>

        {error && (
          <div className="absolute bottom-4 left-0 right-0 flex items-center justify-center text-red-500 dark:text-red-400 text-sm gap-2 animate-pulse bg-red-50 dark:bg-red-900/20 py-2 rounded-lg mx-4">
            <FileWarning size={16} />
            <span>{error}</span>
          </div>
        )}
      </div>
      
      <div className="mt-8 flex items-center justify-center gap-2 text-gray-500 text-sm">
        <CloudLightning size={16} />
        <span>Processamento ultra-rápido via Google Gemini</span>
      </div>
    </div>
  );
};

export default FileUpload;