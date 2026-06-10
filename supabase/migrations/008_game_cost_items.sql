CREATE TABLE game_cost_items (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id     uuid NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  label       text NOT NULL CHECK (char_length(label) <= 50),
  amount_paise integer NOT NULL CHECK (amount_paise >= 0),
  sort_order  integer NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now()
);