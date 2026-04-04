// Supabase Edge Function: recognize face with Face++ and map to member
// Env required: FACEPP_API_KEY, FACEPP_API_SECRET, FACEPP_FACESET_TOKEN
// Optional: FACEPP_API_ENDPOINT (default https://api-us.faceplusplus.com)
// Optional: FACEPP_MIN_CONFIDENCE (default 70)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const FACEPP_API_ENDPOINT = Deno.env.get('FACEPP_API_ENDPOINT') ?? 'https://api-us.faceplusplus.com';
const FACEPP_API_KEY = Deno.env.get('FACEPP_API_KEY');
const FACEPP_API_SECRET = Deno.env.get('FACEPP_API_SECRET');
const FACEPP_FACESET_TOKEN = Deno.env.get('FACEPP_FACESET_TOKEN');
const FACEPP_MIN_CONFIDENCE = Number(Deno.env.get('FACEPP_MIN_CONFIDENCE') ?? '70');

const SUPABASE_URL = Deno.env.get('SUPABASE_URL');
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

function jsonResponse(body: unknown, init: ResponseInit = {}) {
  return new Response(JSON.stringify(body), {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...corsHeaders,
      ...(init.headers ?? {}),
    },
  });
}

async function faceppSearch(imageBase64: string) {
  if (!FACEPP_API_KEY || !FACEPP_API_SECRET || !FACEPP_FACESET_TOKEN) {
    throw new Error('Face++ config missing.');
  }
  const form = new FormData();
  form.append('api_key', FACEPP_API_KEY);
  form.append('api_secret', FACEPP_API_SECRET);
  form.append('faceset_token', FACEPP_FACESET_TOKEN);
  form.append('image_base64', imageBase64);
  form.append('return_result_count', '1');
  const res = await fetch(`${FACEPP_API_ENDPOINT}/facepp/v3/search`, {
    method: 'POST',
    body: form,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Face++ search failed: ${text}`);
  }
  return await res.json();
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const imageBase64 = String(body?.image_base64 ?? '').trim();
    if (!imageBase64) {
      return jsonResponse(
        { member_id: null, confidence: null, error: 'image_base64 is required.' },
        { status: 400 },
      );
    }

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      throw new Error('Supabase service role is not configured.');
    }

    const result = await faceppSearch(imageBase64);
    const results = Array.isArray(result?.results) ? result.results : [];
    if (results.length === 0) {
      return jsonResponse({ member_id: null, confidence: null });
    }

    const best = results[0];
    const confidence = Number(best?.confidence ?? 0);
    const faceToken = String(best?.face_token ?? '').trim();
    if (!faceToken || confidence < FACEPP_MIN_CONFIDENCE) {
      return jsonResponse({ member_id: null, confidence });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    const { data, error } = await supabase
      .from('member_faces')
      .select('member_id')
      .eq('face_token', faceToken)
      .limit(1)
      .maybeSingle();

    if (error) {
      return jsonResponse({ member_id: null, confidence, error: error.message }, { status: 500 });
    }

    return jsonResponse({ member_id: data?.member_id ?? null, confidence });
  } catch (error) {
    return jsonResponse(
      { member_id: null, confidence: null, error: error instanceof Error ? error.message : String(error) },
      { status: 500 },
    );
  }
});
