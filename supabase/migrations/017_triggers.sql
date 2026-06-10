CREATE OR REPLACE FUNCTION transfer_orphaned_game_ownership()
RETURNS TRIGGER AS $$
BEGIN
  -- When a member is removed or leaves, transfer their game payment ownership to host
  IF NEW.status IN ('removed', 'left') THEN
    UPDATE games
    SET payment_owner_id = (
      SELECT host_id FROM groups WHERE id = NEW.group_id
    )
    WHERE group_id = NEW.group_id
      AND payment_owner_id = NEW.user_id
      AND status = 'upcoming';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_member_status_change
  AFTER UPDATE ON group_members
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION transfer_orphaned_game_ownership();


CREATE OR REPLACE FUNCTION check_announcement_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM announcements WHERE group_id = NEW.group_id) >= 5 THEN
    RAISE EXCEPTION 'announcement_limit_reached'
      USING HINT = 'A group may have at most 5 announcements.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_announcement_limit
  BEFORE INSERT ON announcements
  FOR EACH ROW EXECUTE FUNCTION check_announcement_limit();

CREATE OR REPLACE FUNCTION check_cost_item_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) FROM game_cost_items WHERE game_id = NEW.game_id) >= 5 THEN
    RAISE EXCEPTION 'cost_item_limit_reached'
      USING HINT = 'A game may have at most 5 cost breakdown items.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_cost_item_limit
  BEFORE INSERT ON game_cost_items
  FOR EACH ROW EXECUTE FUNCTION check_cost_item_limit();


-- Trigger to automatically create a profile when a new user signs up in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, is_profile_complete)
  VALUES (
    NEW.id,
    SUBSTRING(COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'User_' || SUBSTRING(NEW.id::text FROM 1 FOR 8)) FROM 1 FOR 32),
    FALSE
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


