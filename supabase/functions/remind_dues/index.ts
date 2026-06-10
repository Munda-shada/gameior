import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
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

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', message: 'Invalid token or user not authenticated' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const body = await req.json().catch(() => ({}));
    const groupId = body.groupId?.toString();
    const userId = body.userId?.toString() || null;

    if (!groupId) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'groupId is required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    );

    // 1. Verify caller has admin privileges (host or co_host)
    const { data: callerMember, error: callerError } = await supabaseAdmin
      .from('group_members')
      .select('role')
      .eq('group_id', groupId)
      .eq('user_id', user.id)
      .maybeSingle();

    if (callerError || !callerMember || (callerMember.role !== 'host' && callerMember.role !== 'co_host')) {
      return new Response(
        JSON.stringify({ error: 'forbidden', message: 'Only host or co-host can trigger dues reminders' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 2. Query unpaid dues in this group
    let query = supabaseAdmin
      .from('payment_dues')
      .select('player_id, amount_paise')
      .eq('group_id', groupId)
      .neq('status', 'paid');

    if (userId) {
      query = query.eq('player_id', userId);
    }

    const { data: dues, error: duesError } = await query;
    if (duesError) {
      throw duesError;
    }

    if (!dues || dues.length === 0) {
      return new Response(
        JSON.stringify({ data: { status: 'no_dues', message: 'No unpaid dues found.' } }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // 3. Aggregate unpaid dues amount per player
    const playerDuesMap = new Map<string, number>();
    for (const d of dues) {
      const pId = d.player_id;
      const amount = d.amount_paise || 0;
      playerDuesMap.set(pId, (playerDuesMap.get(pId) || 0) + amount);
    }

    // 4. Send reminders
    let sentCount = 0;
    const sendNotificationUrl = `${Deno.env.get('SUPABASE_URL')}/functions/v1/send_notification`;

    for (const [playerId, totalAmount] of playerDuesMap.entries()) {
      if (totalAmount <= 0) continue;

      // Invoke internal send_notification function
      await fetch(sendNotificationUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
        },
        body: JSON.stringify({
          type: 'dues_reminder',
          userId: playerId,
          groupId,
          amountPaise: totalAmount,
          actorId: user.id,
        }),
      });
      sentCount++;
    }

    return new Response(
      JSON.stringify({ data: { status: 'success', reminders_sent: sentCount } }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
})
