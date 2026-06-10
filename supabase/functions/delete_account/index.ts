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

    // Initialize Admin Client (service_role) to execute writes and bypass RLS
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Fetch groups hosted by this user
    const { data: hostedGroups, error: hostedError } = await supabaseAdmin
      .from('groups')
      .select('id, name')
      .eq('host_id', callerId);

    if (hostedError) {
      throw new Error(`Failed to query hosted groups: ${hostedError.message}`);
    }

    const unresolvedGroups: { id: string, name: string }[] = [];
    const transferOperations: { groupId: string; newHostId: string }[] = [];

    for (const group of (hostedGroups || [])) {
      // Find active co-hosts
      const { data: coHosts, error: coHostsError } = await supabaseAdmin
        .from('group_members')
        .select('user_id')
        .eq('group_id', group.id)
        .eq('role', 'co_host')
        .eq('status', 'active')
        .order('joined_at', { ascending: true })
        .limit(1);

      if (coHostsError) {
        throw new Error(`Failed to query co-hosts for group ${group.name}: ${coHostsError.message}`);
      }

      if (!coHosts || coHosts.length === 0) {
        unresolvedGroups.push({ id: group.id, name: group.name });
      } else {
        transferOperations.push({ groupId: group.id, newHostId: coHosts[0].user_id });
      }
    }

    if (unresolvedGroups.length > 0) {
      return new Response(
        JSON.stringify({
          error: 'groups_unresolved',
          message: 'Resolve all your hosted groups before deleting your account.',
          data: { unresolved_groups: unresolvedGroups }
        }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Execute transfer operations (promote co-host to host)
    for (const op of transferOperations) {
      // Set host_id of group to the new host
      const { error: updateGroupErr } = await supabaseAdmin
        .from('groups')
        .update({ host_id: op.newHostId })
        .eq('id', op.groupId);
      if (updateGroupErr) {
        throw new Error(`Failed to transfer group ownership for ${op.groupId}: ${updateGroupErr.message}`);
      }

      // Set role of new host to 'host' in group_members
      const { error: updateNewHostMemberErr } = await supabaseAdmin
        .from('group_members')
        .update({ role: 'host' })
        .eq('group_id', op.groupId)
        .eq('user_id', op.newHostId);
      if (updateNewHostMemberErr) {
        throw new Error(`Failed to update new host member role: ${updateNewHostMemberErr.message}`);
      }
    }

    // Reassign games where callerId was payment_owner_id to the group's current host
    const { data: games, error: gamesErr } = await supabaseAdmin
      .from('games')
      .select('id, group_id')
      .eq('payment_owner_id', callerId);

    if (gamesErr) {
      throw new Error(`Failed to query games: ${gamesErr.message}`);
    }

    if (games && games.length > 0) {
      for (const game of games) {
        const { data: grp } = await supabaseAdmin
          .from('groups')
          .select('host_id')
          .eq('id', game.group_id)
          .single();
        if (grp) {
          await supabaseAdmin
            .from('games')
            .update({ payment_owner_id: grp.host_id })
            .eq('id', game.id);
        }
      }
    }

    // Reassign payment_dues where callerId was payment_owner_id to the group's current host
    const { data: dues, error: duesErr } = await supabaseAdmin
      .from('payment_dues')
      .select('id, group_id')
      .eq('payment_owner_id', callerId);

    if (duesErr) {
      throw new Error(`Failed to query dues: ${duesErr.message}`);
    }

    if (dues && dues.length > 0) {
      for (const due of dues) {
        const { data: grp } = await supabaseAdmin
          .from('groups')
          .select('host_id')
          .eq('id', due.group_id)
          .single();
        if (grp) {
          await supabaseAdmin
            .from('payment_dues')
            .update({ payment_owner_id: grp.host_id })
            .eq('id', due.id);
        }
      }
    }

    // Reassign group_invites created by callerId to the group's current host
    const { data: invites, error: invitesErr } = await supabaseAdmin
      .from('group_invites')
      .select('id, group_id')
      .eq('created_by', callerId);

    if (invitesErr) {
      throw new Error(`Failed to query invites: ${invitesErr.message}`);
    }

    if (invites && invites.length > 0) {
      for (const invite of invites) {
        const { data: grp } = await supabaseAdmin
          .from('groups')
          .select('host_id')
          .eq('id', invite.group_id)
          .single();
        if (grp) {
          await supabaseAdmin
            .from('group_invites')
            .update({ created_by: grp.host_id })
            .eq('id', invite.id);
        }
      }
    }

    // Reassign announcements created by callerId to the group's current host
    const { data: announcements, error: announcementsErr } = await supabaseAdmin
      .from('announcements')
      .select('id, group_id')
      .eq('created_by', callerId);

    if (announcementsErr) {
      throw new Error(`Failed to query announcements: ${announcementsErr.message}`);
    }

    if (announcements && announcements.length > 0) {
      for (const ann of announcements) {
        const { data: grp } = await supabaseAdmin
          .from('groups')
          .select('host_id')
          .eq('id', ann.group_id)
          .single();
        if (grp) {
          await supabaseAdmin
            .from('announcements')
            .update({ created_by: grp.host_id })
            .eq('id', ann.id);
        }
      }
    }

    // Reassign game completions completed by callerId to the group's current host
    const { data: completions, error: completionsErr } = await supabaseAdmin
      .from('game_completion')
      .select('id, game_id')
      .eq('completed_by', callerId);

    if (completionsErr) {
      throw new Error(`Failed to query completions: ${completionsErr.message}`);
    }

    if (completions && completions.length > 0) {
      for (const comp of completions) {
        const { data: game } = await supabaseAdmin
          .from('games')
          .select('group_id')
          .eq('id', comp.game_id)
          .single();
        if (game) {
          const { data: grp } = await supabaseAdmin
            .from('groups')
            .select('host_id')
            .eq('id', game.group_id)
            .single();
          if (grp) {
            await supabaseAdmin
              .from('game_completion')
              .update({ completed_by: grp.host_id })
              .eq('id', comp.id);
          }
        }
      }
    }

    // Nullify verified_by in payment_dues
    await supabaseAdmin
      .from('payment_dues')
      .update({ verified_by: null })
      .eq('verified_by', callerId);

    // Delete user record from auth.users (which cascades to profiles, group_members, rsvps, notification_tokens, notifications, digest queue)
    const { error: deleteError } = await supabaseAdmin.auth.admin.deleteUser(callerId);
    if (deleteError) {
      throw new Error(`Failed to delete user: ${deleteError.message}`);
    }

    return new Response(
      JSON.stringify({ data: { deleted: true } }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
