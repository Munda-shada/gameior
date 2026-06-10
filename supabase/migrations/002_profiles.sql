CREATE TABLE profiles (
  id                    uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name          text NOT NULL CHECK (char_length(display_name) <= 32),
  phone                 text CHECK (phone ~ '^\+91[0-9]{10}$'),
  emoji                 text NOT NULL DEFAULT '🏸',
  upi_id                text,                          -- personal UPI, pre-fills on game creation
  is_profile_complete   boolean NOT NULL DEFAULT false,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

