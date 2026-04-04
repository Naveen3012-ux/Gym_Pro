// Supabase Edge Function: enroll face with Face++
// Env required: FACEPP_API_KEY, FACEPP_API_SECRET, FACEPP_FACESET_TOKEN
// Optional: FACEPP_API_ENDPOINT (default https://api-us.faceplusplus.com)
// Optional: FACEPP_ENROLL_MIN_CONFIDENCE (unused here)

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const FACEPP_API_ENDPOINT = Deno.env.get('FACEPP_API_ENDPOINT') ?? 'https://api-us.faceplusplus.com';
const FACEPP_API_KEY = Deno.env.get('FACEPP_API_KEY');
const FACEPP_API_SECRET = Deno.env.get('FACEPP_API_SECRET');
const FACEPP_FACESET_TOKEN = Deno.env.get('FACEPP_FACESET_TOKEN');

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

async function faceppDetect(imageBase64: string) {
  if (!FACEPP_API_KEY || !FACEPP_API_SECRET) {
    throw new Error('Face++ credentials are not configured.');
  }
  const form = new FormData();
  form.append('api_key', FACEPP_API_KEY);
  form.append('api_secret', FACEPP_API_SECRET);
  form.append('image_base64', imageBase64);
  form.append('return_attributes', 'none');
  const res = await fetch(`${FACEPP_API_ENDPOINT}/facepp/v3/detect`, {
    method: 'POST',
    body: form,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Face++ detect failed: ${text}`);
  }
  return await res.json();
}

async function faceppAddToFaceSet(faceToken: string) {
  if (!FACEPP_API_KEY || !FACEPP_API_SECRET || !FACEPP_FACESET_TOKEN) {
    throw new Error('Face++ FaceSet config missing.');
  }
  const form = new FormData();
  form.append('api_key', FACEPP_API_KEY);
  form.append('api_secret', FACEPP_API_SECRET);
  form.append('faceset_token', FACEPP_FACESET_TOKEN);
  form.append('face_tokens', faceToken);
  const res = await fetch(`${FACEPP_API_ENDPOINT}/facepp/v3/faceset/addface`, {
    method: 'POST',
    body: form,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`Face++ addface failed: ${text}`);
  }
  return await res.json();
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const body = await req.json();
    const memberId = String(body?.member_id ?? '').trim();
    const imageBase64 = String(body?.image_base64 ?? '').trim();

    if (!memberId || !imageBase64) {
      return jsonResponse(
        { success: false, error: 'member_id and image_base64 are required.' },
        { status: 400 },
      );
    }

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
      throw new Error('Supabase service role is not configured.');
    }

    const detect = await faceppDetect(imageBase64);
    const faces = Array.isArray(detect?.faces) ? detect.faces : [];
    if (faces.length === 0) {
      return jsonResponse(
        { success: false, error: 'No face detected in the image.' },
        { status: 422 },
      );
    }

    const faceToken = faces[0]?.face_token;
    if (!faceToken) {
      return jsonResponse(
        { success: false, error: 'Face token missing from Face++ response.' },
        { status: 422 },
      );
    }

    await faceppAddToFaceSet(faceToken);

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    const { error } = await supabase.from('member_faces').upsert({
      member_id: memberId,
      face_token: faceToken,
    }, { onConflict: 'member_id' });

    if (error) {
      return jsonResponse({ success: false, error: error.message }, { status: 500 });
    }

    return jsonResponse({ success: true, face_token: faceToken });
  } catch (error) {
    return jsonResponse(
      { success: false, error: error instanceof Error ? error.message : String(error) },
      { status: 500 },
    );
  }
});
