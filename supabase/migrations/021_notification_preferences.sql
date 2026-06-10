ALTER TABLE profiles 
  ADD COLUMN notif_game_reminders boolean NOT NULL DEFAULT true,
  ADD COLUMN notif_waitlist_promotions boolean NOT NULL DEFAULT true,
  ADD COLUMN notif_payment_dues boolean NOT NULL DEFAULT true,
  ADD COLUMN notif_matchday_lineups boolean NOT NULL DEFAULT true,
  ADD COLUMN notif_delivery_mode text NOT NULL DEFAULT 'immediate' 
    CONSTRAINT check_delivery_mode CHECK (notif_delivery_mode IN ('immediate', 'daily_digest', 'quiet_hours'));
