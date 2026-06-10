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

    // Parse request body
    const body = await req.json().catch(() => ({}));
    const gameId = body.game_id?.toString();
    const status = body.status?.toString();
    const guestCount = parseInt(body.guest_count?.toString() || '0', 10);
    const userIsPlaying = body.user_is_playing !== false;

    if (!gameId || !status) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Game ID and status are required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Initialize Admin Client (service_role) to bypass RLS and perform operations
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // Call the database function to execute the atomic transaction
    const { data: rpcResult, error: rpcError } = await supabaseAdmin.rpc('fn_rsvp_update', {
      p_game_id: gameId,
      p_user_id: callerId,
      p_status: status,
      p_guest_count: guestCount,
      p_user_is_playing: userIsPlaying
    });

    if (rpcError) {
      // Map postgres function exceptions to clean error responses
      let httpStatus = 500;
      let errorCode = 'internal_error';
      let errorMsg = rpcError.message;

      if (rpcError.message.includes('game_not_found')) {
        httpStatus = 404;
        errorCode = 'not_found';
        errorMsg = 'Game not found.';
      } else if (rpcError.message.includes('game_not_upcoming')) {
        httpStatus = 409;
        errorCode = 'not_found';
        errorMsg = 'Game is not upcoming.';
      } else if (rpcError.message.includes('rsvp_locked')) {
        httpStatus = 409;
        errorCode = 'rsvp_locked';
        errorMsg = 'RSVP window is closed for this session.';
      }

      return new Response(
        JSON.stringify({ error: errorCode, message: errorMsg }),
        { status: httpStatus, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Extract RPC results (it returns a single row matching fn_rsvp_update returns)
    const resultRow = rpcResult[0];
    const finalStatus = resultRow.r_status;
    const waitlistPosition = resultRow.r_waitlist_position;
    let slotsFreed = resultRow.r_slots_freed;
    const paymentModel = resultRow.r_payment_model;
    const costPaise = resultRow.r_cost_paise;
    const paymentOwnerId = resultRow.r_payment_owner_id;
    const groupId = resultRow.r_group_id;

    // Trigger waitlist promotion if slots were freed
    if (slotsFreed > 0) {
      // 1. Fetch all waitlisted players ordered by position
      const { data: waitlisted } = await supabaseAdmin
        .from('rsvps')
        .select('user_id, guest_count, user_is_playing')
        .eq('game_id', gameId)
        .eq('status', 'waitlist')
        .order('waitlist_position', { ascending: true });

      if (waitlisted && waitlisted.length > 0) {
        const promotedIds: string[] = [];
        
        for (const w of waitlisted) {
          const neededSlots = (w.user_is_playing ? 1 : 0) + w.guest_count;
          
          if (neededSlots <= slotsFreed) {
            // Promote this player
            promotedIds.push(w.user_id);
            slotsFreed -= neededSlots;

            // Update RSVP status to confirmed
            await supabaseAdmin
              .from('rsvps')
              .update({
                status: 'yes',
                waitlist_position: null,
                responded_at: new Date().toISOString()
              })
              .eq('game_id', gameId)
              .eq('user_id', w.user_id);

            // Generate prepaid dues if prepaid
            if (paymentModel === 'prepaid') {
              await supabaseAdmin
                .from('payment_dues')
                .upsert({
                  game_id: gameId,
                  group_id: groupId,
                  player_id: w.user_id,
                  payment_owner_id: paymentOwnerId,
                  amount_paise: costPaise * neededSlots,
                  status: 'unpaid'
                });
            }

            // Notification stub (Waitlist promotion alert)
            console.log(`[Notification Placeholder] Waitlist promotion for user ${w.user_id} on game ${gameId}`);
          }
        }

        // 2. Reorder remaining waitlist queue positions
        const { data: remaining } = await supabaseAdmin
          .from('rsvps')
          .select('user_id')
          .eq('game_id', gameId)
          .eq('status', 'waitlist')
          .order('waitlist_position', { ascending: true });

        if (remaining && remaining.length > 0) {
          for (let i = 0; i < remaining.length; i++) {
            await supabaseAdmin
              .from('rsvps')
              .update({ waitlist_position: i + 1 })
              .eq('game_id', gameId)
              .eq('user_id', remaining[i].user_id);
          }
        }
      }
    }

    return new Response(
      JSON.stringify({
        data: {
          status: finalStatus,
          waitlist_position: waitlistPosition,
          message: finalStatus === 'waitlist' ? 'Added to waitlist.' : 'RSVP updated.'
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
