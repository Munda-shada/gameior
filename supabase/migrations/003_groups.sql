CREATE TABLE groups (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name                      text NOT NULL CHECK (char_length(name) <= 60),
  description               text CHECK (char_length(description) <= 300),
  sport                     sport_type NOT NULL,
  host_id                   uuid NOT NULL REFERENCES profiles(id),   -- current Host
  default_venue             text CHECK (char_length(default_venue) <= 100),
  default_maps_link         text,
  max_capacity              integer CHECK (max_capacity BETWEEN 2 AND 200),
  payment_model             payment_model NOT NULL DEFAULT 'prepaid',
  default_cost_paise        integer NOT NULL DEFAULT 0,
  default_upi_id            text,                                     -- host's UPI for group
  club_rules                text CHECK (char_length(club_rules) <= 1000),
  allow_member_invites      boolean NOT NULL DEFAULT true,
  auto_approve_joins        boolean NOT NULL DEFAULT false,
  allow_guests              boolean NOT NULL DEFAULT true,
  show_cost_breakdown       boolean NOT NULL DEFAULT false,
  auto_approve_payments     boolean NOT NULL DEFAULT false,
  created_at                timestamptz NOT NULL DEFAULT now(),
  updated_at                timestamptz NOT NULL DEFAULT now()
);
