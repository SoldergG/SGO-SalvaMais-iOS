import React, { forwardRef, useState } from 'react';
import { Gauge, ChevronLeft, ChevronRight, FastForward } from 'lucide-react';
import { TranscriptionSegment } from '../types';
import { parseTimeStringToSeconds } from '../services/audioUtils';

interface AudioPlayerProps {
  src: string | null;
  segments?: TranscriptionSegment[];
}

const AudioPlayer = forwardRef<HTMLAudioElement, AudioPlayerProps>(({ src, segments = [] }, ref) => {
  const [speed, setSpeed] = useState(1);
  const audioRef = ref as React.MutableRefObject<HTMLAudioElement | null>;

  if (!src) return null;

  const toggleSpeed = () => {
    const speeds = [0.5, 1, 1.5, 2];
    const currentIndex = speeds.indexOf(speed);
    const nextSpeed = speeds[(currentIndex + 1) % speeds.length];
    
    setSpeed(nextSpeed);
    if (audioRef.current) {
      audioRef.current.playbackRate = nextSpeed;
    }
  };

  const jumpSegment = (direction: 'prev' | 'next') => {
    if (!audioRef.current || segments.length === 0) return;
    
    const currentTime = audioRef.current.currentTime;
    // Buffer to ensure we don't just jump to the exact same start time if we are slightly off
    const buffer = 0.5; 

    // Convert all segment times to seconds for comparison
    // We filter for valid timestamps to avoid NaN
    const timePoints = segments
      .map(s => parseTimeStringToSeconds(s.timestamp))
      .filter(t => !isNaN(t))
      .sort((a, b) => a - b);

    let targetTime = -1;

    if (direction === 'next') {
      // Find the first segment that starts after current time + buffer
      const next = timePoints.find(t => t > currentTime + buffer);
      if (next !== undefined) targetTime = next;
    } else {
      // Find the last segment that starts before current time - buffer
      // If we are at the start of a segment, this should jump to the previous one
      const prev = [...timePoints].reverse().find(t => t < currentTime - buffer);
      if (prev !== undefined) targetTime = prev;
      else targetTime = 0; // Jump to start if no previous segment
    }

    if (targetTime !== -1) {
      audioRef.current.currentTime = targetTime;
      audioRef.current.play().catch(e => console.log("Play interrupted", e));
    }
  };

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-white/95 dark:bg-gray-900/95 border-t border-gray-200 dark:border-gray-800 pb-4 pt-2 px-4 z-50 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.1)] backdrop-blur-lg transition-colors duration-300">
      <div className="max-w-7xl mx-auto flex flex-col gap-2">
        
        {/* Custom Controls Toolbar */}
        <div className="flex items-center justify-center sm:justify-between gap-4">
           {/* Speed Control */}
           <button 
            onClick={toggleSpeed}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-100 dark:bg-gray-800 hover:bg-indigo-100 dark:hover:bg-indigo-900/30 text-xs font-medium text-gray-700 dark:text-gray-300 transition-colors"
            title="Velocidade de reprodução"
          >
            <Gauge size={14} className={speed !== 1 ? "text-indigo-600 dark:text-indigo-400" : ""} />
            <span className="w-8 text-center">{speed}x</span>
          </button>

          {/* Navigation Controls */}
          <div className="flex items-center gap-2">
             <button
              onClick={() => jumpSegment('prev')}
              disabled={segments.length === 0}
              className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 disabled:opacity-30 transition-colors"
              title="Segmento Anterior"
            >
              <ChevronLeft size={20} />
            </button>
            
            <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest hidden sm:block">Segmentos</span>

            <button
              onClick={() => jumpSegment('next')}
              disabled={segments.length === 0}
              className="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-600 dark:text-gray-400 disabled:opacity-30 transition-colors"
              title="Próximo Segmento"
            >
              <ChevronRight size={20} />
            </button>
          </div>

          {/* Placeholder for spacing alignment on desktop */}
          <div className="hidden sm:block w-16"></div>
        </div>

        <audio 
          ref={ref}
          controls 
          className="w-full h-8 
            [&::-webkit-media-controls-panel]:bg-gray-50 dark:[&::-webkit-media-controls-panel]:bg-gray-800/50
            [&::-webkit-media-controls-current-time-display]:text-gray-900 dark:[&::-webkit-media-controls-current-time-display]:text-gray-400
            [&::-webkit-media-controls-time-remaining-display]:text-gray-900 dark:[&::-webkit-media-controls-time-remaining-display]:text-gray-400"
          src={src}
          onPlay={() => {
            if (audioRef.current && audioRef.current.playbackRate !== speed) {
              audioRef.current.playbackRate = speed;
            }
          }}
        >
          Seu navegador não suporta o elemento de áudio.
        </audio>
      </div>
    </div>
  );
});

AudioPlayer.displayName = 'AudioPlayer';

export default AudioPlayer;