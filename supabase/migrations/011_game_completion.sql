CREATE TABLE game_completion (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id             uuid NOT NULL REFERENCES games(id) ON DELETE CASCADE UNIQUE,
  completed_by        uuid NOT NULL REFERENCES profiles(id),
  total_cost_paise    integer NOT NULL CHECK (total_cost_paise >= 0),
  charge_all_rsvped   boolean NOT NULL DEFAULT false,  -- false = attended only
  attended_player_ids uuid[] NOT NULL DEFAULT '{}',    -- array of player UUIDs who attended
  per_head_paise      integer NOT NULL,                -- calculated: total / player count
  completed_at        timestamptz NOT NULL DEFAULT now(),
  updated_at          timestamptz NOT NULL DEFAULT now()
);