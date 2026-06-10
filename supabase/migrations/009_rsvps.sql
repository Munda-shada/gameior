CREATE TABLE rsvps (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id           uuid NOT NULL REFERENCES games(id) ON DELETE CASCADE,
  user_id           uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status            rsvp_status NOT NULL DEFAULT 'unanswered',
  guest_count       integer NOT NULL DEFAULT 0 CHECK (guest_count BETWEEN 0 AND 5),
  user_is_playing   boolean NOT NULL DEFAULT true,  -- false if GUEST-only (not playing themselves)
  waitlist_position integer,                         -- NULL unless status = 'waitlist'
  responded_at      timestamptz,                     -- NULL if unanswered
  created_at        timestamptz NOT NULL DEFAULT now(),
  updated_at        timestamptz NOT NULL DEFAULT now(),

  UNIQUE (game_id, user_id)
);