CREATE TABLE audit_logs (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id    uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  actor_id    uuid REFERENCES profiles(id) ON DELETE SET NULL,  -- who performed action
  target_id   uuid REFERENCES profiles(id) ON DELETE SET NULL,  -- who was affected
  action      audit_action NOT NULL,
  metadata    jsonb,                                             -- optional extra context
  created_at  timestamptz NOT NULL DEFAULT now()
);