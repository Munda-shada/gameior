CREATE OR REPLACE FUNCTION public.fn_rsvp_update(
  p_game_id uuid,
  p_user_id uuid,
  p_status rsvp_status,
  p_guest_count integer,
  p_user_is_playing boolean
)
RETURNS TABLE (
  r_status text,
  r_waitlist_position integer,
  r_slots_freed integer,
  r_payment_model text,
  r_cost_paise integer,
  r_payment_owner_id uuid,
  r_group_id uuid
) AS $$
DECLARE
  v_game_status game_status;
  v_rsvp_locked boolean;
  v_rsvp_deadline timestamptz;
  v_max_capacity integer;
  v_payment_model payment_model;
  v_cost_paise integer;
  v_payment_owner_id uuid;
  v_group_id uuid;
  
  v_old_status rsvp_status;
  v_old_guest_count integer;
  v_old_user_is_playing boolean;
  v_old_slots integer;
  
  v_new_slots integer;
  v_confirmed_excluding_caller integer;
  v_available integer;
  v_final_status text;
  v_waitlist_position integer;
  v_slots_freed integer := 0;
BEGIN
  -- Step 1: Lock the game row to prevent concurrent capacity changes
  SELECT status, rsvp_locked, rsvp_deadline, max_capacity, payment_model, cost_paise, payment_owner_id, group_id
  INTO v_game_status, v_rsvp_locked, v_rsvp_deadline, v_max_capacity, v_payment_model, v_cost_paise, v_payment_owner_id, v_group_id
  FROM games
  WHERE id = p_game_id
  FOR UPDATE;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'game_not_found';
  END IF;

  -- Guard checks
  IF v_game_status != 'upcoming' THEN
    RAISE EXCEPTION 'game_not_upcoming';
  END IF;
  
  IF v_rsvp_locked = true THEN
    RAISE EXCEPTION 'rsvp_locked';
  END IF;
  
  IF v_rsvp_deadline IS NOT NULL AND now() > v_rsvp_deadline THEN
    RAISE EXCEPTION 'rsvp_locked';
  END IF;

  -- Step 2: Fetch caller's current RSVP
  SELECT status, guest_count, user_is_playing
  INTO v_old_status, v_old_guest_count, v_old_user_is_playing
  FROM rsvps
  WHERE game_id = p_game_id AND user_id = p_user_id;

  IF NOT FOUND THEN
    v_old_status := 'unanswered';
    v_old_guest_count := 0;
    v_old_user_is_playing := true;
  END IF;

  -- Step 3: Calculate slots caller currently occupies
  IF v_old_status IN ('yes', 'guest') THEN
    v_old_slots := (CASE WHEN v_old_user_is_playing THEN 1 ELSE 0 END) + v_old_guest_count;
  ELSE
    v_old_slots := 0;
  END IF;

  -- Step 4: Calculate slots new RSVP would occupy
  IF p_status IN ('yes', 'guest') THEN
    v_new_slots := (CASE WHEN p_user_is_playing THEN 1 ELSE 0 END) + p_guest_count;
  ELSE
    v_new_slots := 0;
  END IF;

  -- Step 5: Calculate current confirmed count excluding caller
  SELECT COALESCE(SUM(
    (CASE WHEN user_is_playing THEN 1 ELSE 0 END) + guest_count
  ), 0)
  INTO v_confirmed_excluding_caller
  FROM rsvps
  WHERE game_id = p_game_id
    AND status IN ('yes', 'guest')
    AND user_id != p_user_id;

  -- Step 6: Capacity check
  v_final_status := p_status::text;
  v_waitlist_position := NULL;
  
  IF p_status IN ('yes', 'guest') THEN
    v_available := v_max_capacity - v_confirmed_excluding_caller;
    IF v_new_slots > v_available THEN
      v_final_status := 'waitlist';
      -- Get next waitlist position
      SELECT COALESCE(COUNT(*), 0) + 1
      INTO v_waitlist_position
      FROM rsvps
      WHERE game_id = p_game_id AND status = 'waitlist';
    END IF;
  END IF;

  -- Step 7: UPSERT the RSVP
  INSERT INTO rsvps (
    game_id, user_id, status, guest_count, user_is_playing, 
    waitlist_position, responded_at, updated_at
  )
  VALUES (
    p_game_id, p_user_id, v_final_status::rsvp_status, p_guest_count, p_user_is_playing,
    v_waitlist_position, now(), now()
  )
  ON CONFLICT (game_id, user_id) DO UPDATE SET
    status = EXCLUDED.status,
    guest_count = EXCLUDED.guest_count,
    user_is_playing = EXCLUDED.user_is_playing,
    waitlist_position = EXCLUDED.waitlist_position,
    responded_at = EXCLUDED.responded_at,
    updated_at = EXCLUDED.updated_at;

  -- Step 8: Handle prepaid dues generation/cleanup
  IF v_payment_model = 'prepaid' THEN
    IF v_final_status IN ('yes', 'guest') THEN
      INSERT INTO payment_dues (
        game_id, group_id, player_id, payment_owner_id, amount_paise, status, created_at, updated_at
      )
      VALUES (
        p_game_id, v_group_id, p_user_id, v_payment_owner_id, v_cost_paise * v_new_slots, 'unpaid', now(), now()
      )
      ON CONFLICT (game_id, player_id) DO UPDATE SET
        amount_paise = EXCLUDED.amount_paise,
        updated_at = now()
      WHERE payment_dues.status = 'unpaid';
    ELSIF v_final_status IN ('no', 'maybe', 'unanswered', 'waitlist') THEN
      DELETE FROM payment_dues
      WHERE game_id = p_game_id 
        AND player_id = p_user_id
        AND status = 'unpaid';
    END IF;
  END IF;

  -- Step 9: Check if caller was confirmed but is now leaving (to trigger waitlist promotion)
  IF v_old_status IN ('yes', 'guest') AND v_final_status IN ('no', 'maybe', 'unanswered', 'waitlist') THEN
    v_slots_freed := v_old_slots;
  END IF;

  RETURN QUERY SELECT 
    v_final_status, 
    v_waitlist_position, 
    v_slots_freed, 
    v_payment_model::text, 
    v_cost_paise, 
    v_payment_owner_id, 
    v_group_id;
END;
$$ LANGUAGE plpgsql;
