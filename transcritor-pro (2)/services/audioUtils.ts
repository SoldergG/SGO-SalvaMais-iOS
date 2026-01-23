import { AudioChunk } from '../types';

// Converts a Blob/File to Base64 string
export const blobToBase64 = (blob: Blob): Promise<string> => {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const result = reader.result as string;
      // Remove the data URL prefix (e.g., "data:audio/mp3;base64,")
      const base64 = result.split(',')[1];
      resolve(base64);
    };
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
};

// Reads a specific chunk from the file on demand (Lazy Loading)
export const readChunkData = async (file: File, startByte: number, endByte: number): Promise<string> => {
  const blob = file.slice(startByte, endByte, file.type);
  return await blobToBase64(blob);
};

// Generate ONLY metadata (instant), do not load data into memory yet
export const generateAudioChunksMetadata = async (file: File): Promise<AudioChunk[]> => {
  // 1MB per chunk fits safely within API limits
  const CHUNK_SIZE = 1 * 1024 * 1024; 
  const chunks: AudioChunk[] = [];
  const totalSize = file.size;
  let start = 0;
  let chunkId = 0;
  
  // We use the file duration to estimate offset
  const totalDuration = await getBlobDuration(file);
  
  while (start < totalSize) {
    const end = Math.min(start + CHUNK_SIZE, totalSize);
    
    // Estimate time offset based on byte position
    const startTimeOffset = (start / totalSize) * totalDuration;
    
    // NOTE: We do NOT load base64Data here. We leave it undefined.
    // This allows processing GB+ files without crashing the browser memory.
    chunks.push({
      id: chunkId,
      // base64Data is deliberately omitted/undefined here for lazy loading
      mimeType: file.type || 'audio/mp3', 
      startByte: start,
      endByte: end,
      status: 'pending',
      segments: [],
      startTimeOffset: startTimeOffset,
      duration: 0 
    });

    start = end;
    chunkId++;
  }
  
  return chunks;
};

// Kept for backward compatibility if needed, but generateAudioChunksMetadata is preferred
export const processAudioAndChunk = generateAudioChunksMetadata;

export const getBlobDuration = async (blob: Blob | File): Promise<number> => {
  return new Promise((resolve) => {
    const url = URL.createObjectURL(blob);
    const audio = document.createElement('audio');
    audio.preload = 'metadata';
    audio.onloadedmetadata = () => {
      const duration = audio.duration;
      URL.revokeObjectURL(url);
      resolve(duration === Infinity ? 0 : duration);
    };
    audio.onerror = () => {
      URL.revokeObjectURL(url);
      resolve(0); 
    };
    audio.src = url;
  });
};

export const formatTime = (seconds: number): string => {
  if (isNaN(seconds) || seconds < 0) return "00:00";
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = Math.floor(seconds % 60);
  
  const mStr = m.toString().padStart(2, '0');
  const sStr = s.toString().padStart(2, '0');
  
  if (h > 0) {
    return `${h}:${mStr}:${sStr}`;
  }
  return `${mStr}:${sStr}`;
};

export const parseTimeStringToSeconds = (timeStr: string): number => {
  if (!timeStr) return 0;
  // Remove spaces and split
  const parts = timeStr.trim().split(':').map(val => {
    const num = parseInt(val, 10);
    return isNaN(num) ? 0 : num;
  }).reverse();
  
  let seconds = 0;
  if (parts[0]) seconds += parts[0]; // seconds
  if (parts[1]) seconds += parts[1] * 60; // minutes
  if (parts[2]) seconds += parts[2] * 3600; // hours
  return seconds;
};

export const downloadText = (filename: string, text: string) => {
  const element = document.createElement('a');
  const file = new Blob([text], {type: 'text/plain'});
  element.href = URL.createObjectURL(file);
  element.download = filename;
  document.body.appendChild(element); 
  element.click();
  document.body.removeChild(element);
};