CREATE TABLE payment_dues (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id         uuid NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  group_id        uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  player_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  payment_owner_id uuid NOT NULL REFERENCES profiles(id),  -- who receives payment
  amount_paise    integer NOT NULL CHECK (amount_paise >= 0),
  status          due_status NOT NULL DEFAULT 'unpaid',
  utr_reference   text CHECK (utr_reference ~ '^[0-9]{12}$'),  -- 12-digit numeric
  submitted_at    timestamptz,
  verified_at     timestamptz,
  verified_by     uuid REFERENCES profiles(id),
  rejection_count integer NOT NULL DEFAULT 0,
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),

  UNIQUE (game_id, player_id)
);