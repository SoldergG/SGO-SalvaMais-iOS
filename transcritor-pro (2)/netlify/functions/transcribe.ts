import type { Handler } from '@netlify/functions';
import { GoogleGenAI, Type } from '@google/genai';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function safeJsonParse(jsonString: string): any[] {
  try {
    return JSON.parse(jsonString);
  } catch (error) {
    let fixedString = jsonString.trim();
    const lastObjectEnd = fixedString.lastIndexOf('},');

    if (lastObjectEnd !== -1) {
      fixedString = fixedString.substring(0, lastObjectEnd + 1) + ']';
      try {
        return JSON.parse(fixedString);
      } catch {
        const lastBrace = fixedString.lastIndexOf('}');
        if (lastBrace !== -1) {
          fixedString = fixedString.substring(0, lastBrace + 1) + ']';
          return JSON.parse(fixedString);
        }
      }
    }

    throw error;
  }
}

export const handler: Handler = async (event) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: '',
    };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: corsHeaders,
      body: 'Method Not Allowed',
    };
  }

  const apiKey = process.env.GEMINI_API_KEY || process.env.API_KEY;
  if (!apiKey) {
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: 'Missing GEMINI_API_KEY',
    };
  }

  let payload: any;
  try {
    payload = JSON.parse(event.body || '{}');
  } catch {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: 'Invalid JSON body',
    };
  }

  const base64Data = payload?.base64Data;
  const mimeType = payload?.mimeType || 'audio/mp3';
  const previousContext = payload?.previousContext || '';
  const knownSpeakers = Array.isArray(payload?.knownSpeakers) ? payload.knownSpeakers : [];

  if (!base64Data || typeof base64Data !== 'string') {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: 'Missing base64Data',
    };
  }

  const ai = new GoogleGenAI({ apiKey });

  const responseSchema = {
    type: Type.ARRAY,
    items: {
      type: Type.OBJECT,
      properties: {
        speaker: {
          type: Type.STRING,
          description: 'Nome do orador. MANTENHA CONSISTÊNCIA com a lista de oradores conhecidos se a voz coincidir.',
        },
        timestamp: {
          type: Type.STRING,
          description: 'Timestamp relativo ao inicio do áudio fornecido (MM:SS).',
        },
        text: {
          type: Type.STRING,
          description: 'O texto transcrito exato.',
        },
      },
      propertyOrdering: ['timestamp', 'speaker', 'text'],
      required: ['speaker', 'timestamp', 'text'],
    },
  };

  const speakerInstruction =
    knownSpeakers.length > 0
      ? `
      ATENÇÃO AOS ORADORES:
      Já identificamos estes oradores nas partes anteriores do áudio: ${knownSpeakers.join(', ')}.
      1. Se reconhecer uma voz similar, USE O MESMO NOME da lista acima.
      2. Se for uma voz claramente nova, use "Orador ${knownSpeakers.length + 1}", "Orador ${knownSpeakers.length + 2}", etc.
      3. Seja consistente.`
      : 'Identifique oradores genéricos como "Orador 1", "Orador 2", etc.';

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.0-flash-exp',
      contents: {
        parts: [
          {
            inlineData: {
              mimeType,
              data: base64Data,
            },
          },
          {
            text: `
            Tarefa: Transcrever áudio para Português (Brasil) com diarização (identificação de oradores).

            Contexto dos últimos segundos da parte anterior (para continuidade): "...${String(previousContext).slice(-300)}..."

            ${speakerInstruction}

            Requisito de Formato: Retorne APENAS um JSON array válido. Sem markdown, sem explicações.
            `,
          },
        ],
      },
      config: {
        responseMimeType: 'application/json',
        responseSchema,
        temperature: 0.1,
      },
    });

    const jsonText = response.text;
    if (!jsonText) {
      return {
        statusCode: 502,
        headers: {
          ...corsHeaders,
          'content-type': 'text/plain; charset=utf-8',
        },
        body: 'Empty response from Gemini',
      };
    }

    const segments = safeJsonParse(jsonText);

    return {
      statusCode: 200,
      headers: {
        ...corsHeaders,
        'content-type': 'application/json; charset=utf-8',
      },
      body: JSON.stringify(segments),
    };
  } catch (error: any) {
    const msg = error?.message || error?.toString?.() || 'Unknown error';

    return {
      statusCode: 500,
      headers: {
        ...corsHeaders,
        'content-type': 'text/plain; charset=utf-8',
      },
      body: msg,
    };
  }
};
