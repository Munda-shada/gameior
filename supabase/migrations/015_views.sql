CREATE VIEW v_member_stats AS
SELECT
  gm.group_id,
  gm.user_id,
  COUNT(r.id) FILTER (WHERE r.status IN ('yes', 'guest'))           AS games_rsvped,
  COUNT(r.id) FILTER (WHERE r.status = 'yes' OR r.status = 'guest') AS games_confirmed,
  ROUND(
    COUNT(r.id) FILTER (WHERE r.status IN ('yes', 'guest'))::numeric
    / NULLIF(COUNT(r.id) FILTER (WHERE r.status != 'unanswered'), 0) * 100
  , 1)                                                               AS attendance_pct,
  gm.joined_at
FROM group_members gm
LEFT JOIN games g ON g.group_id = gm.group_id AND g.status = 'completed'
LEFT JOIN rsvps r ON r.game_id = g.id AND r.user_id = gm.user_id
WHERE gm.status = 'active'
GROUP BY gm.group_id, gm.user_id, gm.joined_at;

CREATE VIEW v_player_dues_summary AS
SELECT
  player_id,
  group_id,
  SUM(amount_paise) FILTER (WHERE status IN ('unpaid', 'pending_verification')) AS pending_paise,
  SUM(amount_paise) FILTER (WHERE status = 'paid')                              AS paid_paise,
  COUNT(*) FILTER (WHERE status IN ('unpaid', 'pending_verification'))          AS unpaid_count
FROM payment_dues
GROUP BY player_id, group_id;