import { TranscriptionSegment } from "../types";

const TRANSCRIBE_ENDPOINT = '/.netlify/functions/transcribe';

function isTranscriptionSegmentArray(value: unknown): value is TranscriptionSegment[] {
  if (!Array.isArray(value)) return false;
  return value.every(item => {
    if (!item || typeof item !== 'object') return false;
    const seg = item as Record<string, unknown>;
    return (
      typeof seg.speaker === 'string' &&
      typeof seg.timestamp === 'string' &&
      typeof seg.text === 'string'
    );
  });
}

export const transcribeAudioChunk = async (
  base64Data: string, 
  mimeType: string = 'audio/mp3', 
  previousContext: string = '',
  knownSpeakers: string[] = []
): Promise<TranscriptionSegment[]> => {
  try {
    const httpResponse = await fetch(TRANSCRIBE_ENDPOINT, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        base64Data,
        mimeType,
        previousContext,
        knownSpeakers,
      }),
    });

    if (!httpResponse.ok) {
      const text = await httpResponse.text().catch(() => '');
      throw new Error(text || `Falha na transcrição (HTTP ${httpResponse.status})`);
    }

    const json = (await httpResponse.json()) as unknown;
    if (!isTranscriptionSegmentArray(json)) throw new Error('Resposta inválida do servidor');

    return json;

  } catch (error: any) {
    console.error("Gemini Transcription Error:", error);
    // Extract meaningful error message if possible
    const msg = error?.message || error?.toString() || "Erro desconhecido";
    throw new Error("Erro ao processar: " + msg);
  }
};