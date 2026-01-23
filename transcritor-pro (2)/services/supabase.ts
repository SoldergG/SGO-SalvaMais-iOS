import { createClient } from '@supabase/supabase-js';

// Helper to safely get env vars regardless of the build tool (Vite, CRA, etc)
const getEnv = (key: string) => {
  try {
    // Check for Vite (import.meta.env)
    // @ts-ignore
    if (typeof import.meta !== 'undefined' && import.meta.env && import.meta.env[key]) {
      // @ts-ignore
      return import.meta.env[key];
    }
  } catch (e) {
    // Ignore errors accessing import.meta
  }

  try {
    // Check for process.env (Standard Node/CRA)
    if (typeof process !== 'undefined' && process.env && process.env[key]) {
      return process.env[key];
    }
  } catch (e) {
    // Ignore errors accessing process
  }
  
  return '';
};

// Fallback keys provided by user (ensures app works even if .env fails to load)
const FALLBACK_URL = "https://lectlnhxfvlomnpmoaof.supabase.co";
const FALLBACK_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxlY3Rsbmh4ZnZsb21ucG1vYW9mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MDQ3MTgsImV4cCI6MjA4MTk4MDcxOH0.wC2E76uXUyQmY5NvWH-p3_8a1cZrjdlaZni267OpHLs";

// Try to load keys from environment variables first, then fallback to hardcoded values
const SUPABASE_URL = getEnv('VITE_SUPABASE_URL') || getEnv('REACT_APP_SUPABASE_URL') || FALLBACK_URL;
const SUPABASE_ANON_KEY = getEnv('VITE_SUPABASE_ANON_KEY') || getEnv('REACT_APP_SUPABASE_ANON_KEY') || FALLBACK_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error(
    "CRITICAL: Supabase Keys missing! The application will crash. Please check services/supabase.ts or your .env configuration."
  );
}

// Ensure URL is at least a non-empty string to avoid "supabaseUrl is required" error during init
export const supabase = createClient(
  SUPABASE_URL || 'https://placeholder.supabase.co', 
  SUPABASE_ANON_KEY || 'placeholder'
);