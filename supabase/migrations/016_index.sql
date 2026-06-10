CREATE INDEX idx_profiles_phone ON profiles(phone);
CREATE INDEX idx_groups_host_id ON groups(host_id);
CREATE INDEX idx_group_members_group_id ON group_members(group_id);
CREATE INDEX idx_group_members_user_id  ON group_members(user_id);
CREATE INDEX idx_group_members_status   ON group_members(group_id, status);
CREATE INDEX idx_games_group_id        ON games(group_id, scheduled_at ASC);
CREATE INDEX idx_games_payment_owner   ON games(payment_owner_id);
CREATE INDEX idx_games_status          ON games(group_id, status);
CREATE INDEX idx_announcements_group_id ON announcements(group_id, created_at DESC);
CREATE INDEX idx_rsvps_game_id     ON rsvps(game_id, status);
CREATE INDEX idx_rsvps_user_id     ON rsvps(user_id);
CREATE INDEX idx_rsvps_waitlist    ON rsvps(game_id, waitlist_position) WHERE status = 'waitlist';
CREATE INDEX idx_dues_player_id       ON payment_dues(player_id, status);
CREATE INDEX idx_dues_payment_owner   ON payment_dues(payment_owner_id, status);
CREATE INDEX idx_dues_game_id         ON payment_dues(game_id);
CREATE INDEX idx_dues_group_player    ON payment_dues(group_id, player_id);
CREATE INDEX idx_audit_group_id   ON audit_logs(group_id, created_at DESC);
CREATE INDEX idx_audit_target_id  ON audit_logs(target_id);

