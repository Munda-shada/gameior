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
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', message: 'No authorization header provided' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Supabase Client with User's JWT
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    )

    // Get calling user details
    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'unauthorized', message: 'Invalid token or user not authenticated' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const callerId = user.id

    // Parse request body
    const body = await req.json().catch(() => ({}))
    const gameId = body.game_id?.toString()
    const totalCostPaise = parseInt(body.total_cost_paise?.toString() || '-1', 10)
    const chargeAllRsvped = body.charge_all_rsvped === true
    const attendedPlayerIds = Array.isArray(body.attended_player_ids)
        ? body.attended_player_ids.map((id: any) => id.toString())
        : []

    // Validation
    if (!gameId) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Game ID is required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (totalCostPaise < 0) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Total cost must be greater than or equal to 0' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (attendedPlayerIds.length === 0) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'At least one attendee is required' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Check duplicates in attendedPlayerIds
    const hasDuplicates = new Set(attendedPlayerIds).size !== attendedPlayerIds.length
    if (hasDuplicates) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Attendee list contains duplicate IDs' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Initialize Admin Client (service_role) to bypass RLS and perform operations
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Fetch game details to verify permissions
    const { data: game, error: gameError } = await supabaseAdmin
      .from('games')
      .select('payment_owner_id, status, payment_model, group_id')
      .eq('id', gameId)
      .single()

    if (gameError || !game) {
      return new Response(
        JSON.stringify({ error: 'not_found', message: 'Game not found.' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Permissions check
    if (game.payment_owner_id !== callerId) {
      return new Response(
        JSON.stringify({ error: 'forbidden', message: 'Only the game creator can complete this game.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (game.status !== 'upcoming') {
      return new Response(
        JSON.stringify({ error: 'completion_locked', message: 'This game is already completed.' }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (game.payment_model !== 'postpaid') {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Game payment model must be postpaid to be completed.' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 1: Validate attended_player_ids are all active members of the group
    const { data: members, error: membersError } = await supabaseAdmin
      .from('group_members')
      .select('user_id')
      .eq('group_id', game.group_id)
      .eq('status', 'active')
      .in('user_id', attendedPlayerIds)

    if (membersError || !members || members.length !== attendedPlayerIds.length) {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Attendee list contains non-members or inactive members.' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 2: Determine who gets charged
    let chargedPlayerIds: string[] = []
    if (chargeAllRsvped) {
      const { data: rsvps, error: rsvpsError } = await supabaseAdmin
        .from('rsvps')
        .select('user_id')
        .eq('game_id', gameId)
        .in('status', ['yes', 'guest'])

      if (rsvpsError || !rsvps || rsvps.length === 0) {
        // Fallback to attended players if no one RSVP'd YES/GUEST
        chargedPlayerIds = attendedPlayerIds
      } else {
        chargedPlayerIds = rsvps.map((r) => r.user_id)
      }
    } else {
      chargedPlayerIds = attendedPlayerIds
    }

    // Step 3: Calculate per-head amount
    const playerCount = chargedPlayerIds.length
    const perHeadPaise = Math.ceil(totalCostPaise / playerCount)

    // Step 4: Insert game_completion record
    const { error: completionError } = await supabaseAdmin
      .from('game_completion')
      .insert({
        game_id: gameId,
        completed_by: callerId,
        total_cost_paise: totalCostPaise,
        charge_all_rsvped: chargeAllRsvped,
        attended_player_ids: attendedPlayerIds,
        per_head_paise: perHeadPaise
      })

    if (completionError) {
      return new Response(
        JSON.stringify({ error: 'completion_locked', message: 'This game is already completed.' }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 5: Bulk insert payment_dues
    const duesInserts = chargedPlayerIds.map((playerId) => ({
      game_id: gameId,
      group_id: game.group_id,
      player_id: playerId,
      payment_owner_id: callerId,
      amount_paise: perHeadPaise,
      status: 'unpaid'
    }))

    const { error: duesError } = await supabaseAdmin
      .from('payment_dues')
      .insert(duesInserts)

    if (duesError) {
      // Clean up completion record to keep transaction atomic
      await supabaseAdmin.from('game_completion').delete().eq('game_id', gameId)
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to create payment dues: ' + duesError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 6: Update game status
    const { error: updateGameError } = await supabaseAdmin
      .from('games')
      .update({ status: 'completed', updated_at: new Date().toISOString() })
      .eq('id', gameId)

    if (updateGameError) {
      // Rollback previous steps
      await supabaseAdmin.from('game_completion').delete().eq('game_id', gameId)
      await supabaseAdmin.from('payment_dues').delete().eq('game_id', gameId)
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to update game status: ' + updateGameError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Stub notification logging
    for (const playerId of chargedPlayerIds) {
      console.log(`[Notification Placeholder] Dues of ₹${(perHeadPaise / 100).toFixed(2)} generated for player ${playerId}`)
    }

    return new Response(
      JSON.stringify({
        data: {
          game_status: 'completed',
          player_count: playerCount,
          per_head_paise: perHeadPaise,
          total_cost_paise: totalCostPaise,
          dues_created: playerCount
        }
      }),
      { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (err) {
    return new Response(
      JSON.stringify({ error: 'internal_error', message: err.message || 'Unexpected server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
