CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Auto-lock RSVP every 5 minutes
SELECT cron.schedule(
  'auto-lock-rsvp',
  '*/5 * * * *',
  $$
    UPDATE games
    SET rsvp_locked = true, updated_at = now()
    WHERE rsvp_deadline IS NOT NULL
      AND rsvp_deadline <= now()
      AND rsvp_locked = false
      AND status = 'upcoming';
  $$
);

-- Daily digest cron. Runs daily at 8:30 PM IST (3:00 PM UTC)
SELECT cron.schedule(
  'send-daily-digest',
  '30 15 * * *',
  $$
    SELECT
      net.http_post(
        url := 'http://kong:8000/functions/v1/send_daily_digest',
        headers := '{"Content-Type": "application/json"}'::jsonb,
        body := '{}'::jsonb
      );
  $$
);
