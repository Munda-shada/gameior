CREATE TABLE games (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id              uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  payment_owner_id      uuid NOT NULL REFERENCES profiles(id),  -- creator; owns payments
  title                 text NOT NULL CHECK (char_length(title) <= 60),
  description           text CHECK (char_length(description) <= 300),
  sport                 sport_type NOT NULL,
  venue                 text NOT NULL CHECK (char_length(venue) <= 100),
  maps_link             text,
  scheduled_at          timestamptz NOT NULL,
  duration_minutes      integer NOT NULL CHECK (duration_minutes > 0),
  max_capacity          integer NOT NULL CHECK (max_capacity BETWEEN 2 AND 200),
  allowed_skill_levels  skill_level[] NOT NULL DEFAULT '{all}',
  payment_model         payment_model NOT NULL,
  cost_paise            integer NOT NULL DEFAULT 0,
  upi_id                text NOT NULL,                          -- payment owner's UPI for this game
  show_cost_breakdown   boolean NOT NULL DEFAULT false,
  allow_guests          boolean NOT NULL DEFAULT true,
  rsvp_deadline         timestamptz,                            -- NULL = no deadline
  rsvp_locked           boolean NOT NULL DEFAULT false,
  status                game_status NOT NULL DEFAULT 'upcoming',
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);