import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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

    // Parse invite code from body
    const body = await req.json().catch(() => ({}));
    const inviteCode = body.invite_code?.toString().toUpperCase().trim();

    if (!inviteCode) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Invite code is required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Admin Client (service_role) to execute writes and bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // 1. Fetch group_id from invites
    const { data: inviteData, error: inviteError } = await supabaseAdmin
      .from('group_invites')
      .select('group_id')
      .eq('code', inviteCode)
      .maybeSingle();

    if (inviteError || !inviteData) {
      return new Response(
        JSON.stringify({ error: 'invalid_invite_code', message: 'This invite code is invalid.' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const groupId = inviteData.group_id;

    // 2. Fetch auto_approve setting
    const { data: groupData, error: groupError } = await supabaseAdmin
      .from('groups')
      .select('id, name, auto_approve_joins')
      .eq('id', groupId)
      .maybeSingle();

    if (groupError || !groupData) {
      return new Response(
        JSON.stringify({ error: 'not_found', message: 'Group not found.' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 3. Fetch existing membership status
    const { data: existingMember, error: memberError } = await supabaseAdmin
      .from('group_members')
      .select('id, status')
      .eq('group_id', groupId)
      .eq('user_id', callerId)
      .maybeSingle();

    if (existingMember) {
      const status = existingMember.status;
      if (status === 'active' || status === 'pending_approval') {
        return new Response(
          JSON.stringify({ error: 'already_member', message: "You're already in this group." }),
          { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }
    }

    const autoApprove = groupData.auto_approve_joins;
    const finalStatus = autoApprove ? 'active' : 'pending_approval';

    // 4. Upsert membership
    const { error: upsertError } = await supabaseAdmin
      .from('group_members')
      .upsert({
        group_id: groupId,
        user_id: callerId,
        role: 'player',
        status: finalStatus,
        joined_at: autoApprove ? new Date().toISOString() : null,
        updated_at: new Date().toISOString(),
      });

    if (upsertError) {
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to update membership.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 5. If auto-approved, log in audit logs. If not, notification is triggered
    if (autoApprove) {
      await supabaseAdmin.from('audit_logs').insert({
        group_id: groupId,
        actor_id: callerId,
        target_id: callerId,
        action: 'member_joined',
      });
    } else {
      // Trigger notification placeholder (for Sprint 6 Fcm integration)
      console.log(`[Notification Placeholder] New join request by ${callerId} for group ${groupId}`);
    }

    // 6. Return response
    const responsePayload = autoApprove
      ? { status: 'active', message: 'Welcome to the group!' }
      : { status: 'pending_approval', message: 'Request sent. Waiting for host approval.' };

    return new Response(
      JSON.stringify({ data: responsePayload }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
