CREATE TABLE notification_digest_queue (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  payload      jsonb NOT NULL,
  created_at   timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE notification_digest_queue ENABLE ROW LEVEL SECURITY;
