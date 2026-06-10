CREATE TABLE notifications (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title        text NOT NULL,
  body         text NOT NULL,
  payload      jsonb NOT NULL,
  read_at      timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications: select self" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "notifications: update self" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
