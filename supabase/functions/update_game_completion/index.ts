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
        JSON.stringify({ error: 'forbidden', message: 'Only the game creator can edit completion details.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (game.status !== 'completed') {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Game is not completed.' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
    if (game.payment_model !== 'postpaid') {
      return new Response(
        JSON.stringify({ error: 'validation_error', message: 'Game payment model must be postpaid.' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Guard Check: Verify that there are unsettled dues (unpaid, pending_verification, or rejected).
    // If all dues are paid (or there are no dues at all), block edits.
    const { data: duesCountData, error: duesCountError } = await supabaseAdmin
      .from('payment_dues')
      .select('status')
      .eq('game_id', gameId)

    if (duesCountError) {
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to count dues: ' + duesCountError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const allDues = duesCountData || []
    const unsettledCount = allDues.filter((d) => d.status !== 'paid').length
    if (unsettledCount === 0 && allDues.length > 0) {
      return new Response(
        JSON.stringify({ error: 'completion_locked', message: "This game's completion is locked because all dues have been settled." }),
        { status: 409, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
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
        chargedPlayerIds = attendedPlayerIds
      } else {
        chargedPlayerIds = rsvps.map((r) => r.user_id)
      }
    } else {
      chargedPlayerIds = attendedPlayerIds
    }

    const playerCount = chargedPlayerIds.length
    const perHeadPaise = Math.ceil(totalCostPaise / playerCount)

    // Fetch current completion record
    const { data: currentCompletion } = await supabaseAdmin
      .from('game_completion')
      .select('total_cost_paise, charge_all_rsvped, attended_player_ids, per_head_paise')
      .eq('game_id', gameId)
      .single()

    // Step 3: Update game_completion record
    const { error: completionError } = await supabaseAdmin
      .from('game_completion')
      .update({
        total_cost_paise: totalCostPaise,
        charge_all_rsvped: chargeAllRsvped,
        attended_player_ids: attendedPlayerIds,
        per_head_paise: perHeadPaise,
        updated_at: new Date().toISOString()
      })
      .eq('game_id', gameId)

    if (completionError) {
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to update completion record: ' + completionError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 4: Update amount_paise on all UNPAID dues for this game
    const { error: updateUnpaidDuesError } = await supabaseAdmin
      .from('payment_dues')
      .update({
        amount_paise: perHeadPaise,
        updated_at: new Date().toISOString()
      })
      .eq('game_id', gameId)
      .eq('status', 'unpaid')

    if (updateUnpaidDuesError) {
      // Rollback completion to previous values
      if (currentCompletion) {
        await supabaseAdmin.from('game_completion').update(currentCompletion).eq('game_id', gameId)
      }
      return new Response(
        JSON.stringify({ error: 'internal_error', message: 'Failed to update unpaid dues: ' + updateUnpaidDuesError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Step 5: Add dues for newly added players
    const existingPlayerIds = new Set(allDues.map((d) => d.player_id))
    const newlyAddedPlayerIds = chargedPlayerIds.filter((id) => !existingPlayerIds.has(id))
    let duesAdded = 0

    if (newlyAddedPlayerIds.length > 0) {
      const newDues = newlyAddedPlayerIds.map((playerId) => ({
        game_id: gameId,
        group_id: game.group_id,
        player_id: playerId,
        payment_owner_id: game.payment_owner_id,
        amount_paise: perHeadPaise,
        status: 'unpaid'
      }))

      const { error: insertNewDuesError } = await supabaseAdmin
        .from('payment_dues')
        .insert(newDues)

      if (insertNewDuesError) {
        return new Response(
          JSON.stringify({ error: 'internal_error', message: 'Failed to insert new dues: ' + insertNewDuesError.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      duesAdded = newlyAddedPlayerIds.length
    }

    // Step 6: Delete unpaid dues for players removed from the charged list
    const removedPlayerIds = Array.from(existingPlayerIds).filter((id) => !chargedPlayerIds.includes(id))
    let duesRemoved = 0

    if (removedPlayerIds.length > 0) {
      const { data: deletedDues, error: deleteDuesError } = await supabaseAdmin
        .from('payment_dues')
        .delete()
        .eq('game_id', gameId)
        .eq('status', 'unpaid')
        .in('player_id', removedPlayerIds)
        .select('player_id')

      if (deleteDuesError) {
        return new Response(
          JSON.stringify({ error: 'internal_error', message: 'Failed to delete removed player dues: ' + deleteDuesError.message }),
          { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        )
      }
      duesRemoved = deletedDues?.length || 0
    }

    // Count how many unpaid dues were updated
    const duesUpdated = allDues.filter((d) => d.status === 'unpaid' && chargedPlayerIds.includes(d.player_id)).length

    return new Response(
      JSON.stringify({
        data: {
          updated: true,
          per_head_paise: perHeadPaise,
          dues_updated: duesUpdated,
          dues_added: duesAdded,
          dues_removed: duesRemoved
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
