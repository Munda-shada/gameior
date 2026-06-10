CREATE TABLE announcements (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id     uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  created_by   uuid NOT NULL REFERENCES profiles(id),
  message      text NOT NULL CHECK (char_length(message) <= 500),
  linked_game_id uuid REFERENCES games(id) ON DELETE SET NULL,  -- optional deep link
  created_at   timestamptz NOT NULL DEFAULT now(),
  updated_at   timestamptz NOT NULL DEFAULT now()
);