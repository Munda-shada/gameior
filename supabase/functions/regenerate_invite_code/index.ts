import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function generateInviteCode(): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No ambiguous characters (0/O, 1/I)
  let code = '';
  for (let i = 0; i < 6; i++) {
    const randomIndex = Math.floor(Math.random() * chars.length);
    code += chars[randomIndex];
  }
  return code;
}

Deno.serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', message: 'No authorization header provided' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Supabase Client with User's JWT
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    );

    // Get calling user details
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', message: 'Invalid token or user not authenticated' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const callerId = user.id;

    // Parse group_id from body
    const body = await req.json().catch(() => ({}));
    const groupId = body.group_id?.toString();

    if (!groupId) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Group ID is required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Admin Client (service_role) to execute writes and bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Check permissions: Caller must be active host or co_host
    const { data: memberData, error: memberError } = await supabaseAdmin
      .from('group_members')
      .select('role')
      .eq('group_id', groupId)
      .eq('user_id', callerId)
      .eq('status', 'active')
      .maybeSingle();

    if (memberError || !memberData || !['host', 'co_host'].includes(memberData.role)) {
      return new Response(
        JSON.stringify({ error: 'forbidden', message: 'Only hosts and co-hosts can regenerate invite codes.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Generate a unique 6-character code with collision detection (up to 5 attempts)
    let newCode = '';
    let isUnique = false;
    for (let attempt = 0; attempt < 5; attempt++) {
      const candidateCode = generateInviteCode();
      const { data: existingCode } = await supabaseAdmin
        .from('group_invites')
        .select('id')
        .eq('code', candidateCode)
        .maybeSingle();

      if (!existingCode) {
        newCode = candidateCode;
        isUnique = true;
        break;
      }
    }

    if (!isUnique) {
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to generate a unique invite code after 5 attempts' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Upsert the regenerated invite code
    const { error: upsertError } = await supabaseAdmin
      .from('group_invites')
      .upsert({
        group_id: groupId,
        code: newCode,
        created_by: callerId,
      });

    if (upsertError) {
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to save regenerated invite code.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({ data: { code: newCode } }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
