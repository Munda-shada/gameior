-- Drop trigger and function if they exist
DROP TRIGGER IF EXISTS tr_group_members_audit ON group_members;
DROP FUNCTION IF EXISTS log_membership_audit_events();

-- Trigger function to automatically log membership changes to audit_logs
CREATE OR REPLACE FUNCTION log_membership_audit_events()
RETURNS TRIGGER AS $$
DECLARE
  v_action audit_action;
  v_actor uuid;
  v_metadata jsonb;
BEGIN
  -- Get user executing the transaction (fallback to member's id for background/auto tasks)
  v_actor := COALESCE(auth.uid(), NEW.user_id);

  IF TG_OP = 'UPDATE' THEN
    -- Join request accepted
    IF OLD.status = 'pending_approval' AND NEW.status = 'active' THEN
      v_action := 'join_request_accepted';
    -- Join request rejected
    ELSIF OLD.status = 'pending_approval' AND NEW.status = 'removed' THEN
      v_action := 'join_request_rejected';
    -- Member removed by admin
    ELSIF OLD.status = 'active' AND NEW.status = 'removed' THEN
      v_action := 'member_removed';
      v_metadata := jsonb_build_object('reason', 'admin_action');
    -- Member left on their own
    ELSIF OLD.status = 'active' AND NEW.status = 'left' THEN
      v_action := 'member_left';
      v_actor := NEW.user_id; -- self-action
    -- Role changed
    ELSIF OLD.role != NEW.role THEN
      IF NEW.role = 'co_host' THEN
        v_action := 'role_promoted';
        v_metadata := jsonb_build_object('old_role', OLD.role, 'new_role', NEW.role);
      ELSIF NEW.role = 'player' THEN
        v_action := 'role_demoted';
        v_metadata := jsonb_build_object('old_role', OLD.role, 'new_role', NEW.role);
      ELSIF NEW.role = 'host' THEN
        v_action := 'ownership_transferred';
        v_metadata := jsonb_build_object('old_host_id', OLD.user_id, 'new_host_id', NEW.user_id);
      END IF;
    END IF;
  ELSIF TG_OP = 'INSERT' THEN
    -- Member joined directly (auto-approved invite code)
    IF NEW.status = 'active' THEN
      v_action := 'member_joined';
    END IF;
  END IF;

  IF v_action IS NOT NULL THEN
    INSERT INTO audit_logs (group_id, actor_id, target_id, action, metadata)
    VALUES (NEW.group_id, v_actor, NEW.user_id, v_action, v_metadata);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind trigger to group_members table
CREATE TRIGGER tr_group_members_audit
  AFTER INSERT OR UPDATE ON group_members
  FOR EACH ROW EXECUTE FUNCTION log_membership_audit_events();
