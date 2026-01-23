export interface TranscriptionSegment {
  speaker: string;
  timestamp: string;
  text: string;
  originalTimestamp?: string; // internal use for relative time
}

export interface AudioChunk {
  id: number;
  base64Data?: string; // Base64 encoded audio
  mimeType?: string;
  startByte: number;
  endByte: number;
  status: 'pending' | 'processing' | 'completed' | 'error';
  segments: TranscriptionSegment[]; 
  duration?: number; // duration in seconds
  startTimeOffset?: number; // start time in seconds relative to full audio
  error?: string;
}

export interface TranscriptionState {
  fileName: string;
  fileSize: number;
  totalChunks: number;
  processedChunks: number;
  isProcessing: boolean;
  chunks: AudioChunk[];
}

export enum ProcessingStatus {
  IDLE = 'IDLE',
  ANALYZING = 'ANALYZING',
  TRANSCRIBING = 'TRANSCRIBING',
  COMPLETED = 'COMPLETED',
  ERROR = 'ERROR'
}

// --- NEW TYPES FOR ROLES & CUSTOMIZATION ---

export type UserRole = 'free' | 'admin' | 'super_admin';

export interface UserProfile {
  id: string;
  email: string;
  role: UserRole;
  is_approved: boolean;
  usage_count: number;
  max_usage_limit: number;
  team_id?: string;
  created_at: string;
}

export type FontFamily = 'inter' | 'lora' | 'mono' | 'oswald';
export type FontSize = 'small' | 'medium' | 'large' | 'xlarge';

export interface AppSettings {
  fontFamily: FontFamily;
  fontSize: FontSize;
  theme: 'light' | 'dark';
}
