-- Users can read their own profile
CREATE POLICY "profiles: select own" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "profiles: update own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Profile is readable by any authenticated user (for member lists, rosters)
CREATE POLICY "profiles: select any authenticated" ON profiles
  FOR SELECT USING (auth.role() = 'authenticated');

-- Users can insert their own profile
CREATE POLICY "profiles: insert own" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);



-- Any active member can read the group
CREATE POLICY "groups: select for active members" ON groups
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = groups.id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Only host or co_host can update group settings
CREATE POLICY "groups: update for admins" ON groups
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = groups.id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );

-- Only host can delete
CREATE POLICY "groups: delete for host" ON groups
  FOR DELETE USING (host_id = auth.uid());

-- Active members can see all members in their group
CREATE POLICY "group_members: select for active members" ON group_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.status = 'active'
    )
  );

-- Admins can insert (approve join requests) and update roles/status
CREATE POLICY "group_members: admin write" ON group_members
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members gm
      WHERE gm.group_id = group_members.group_id
        AND gm.user_id = auth.uid()
        AND gm.role IN ('host', 'co_host')
        AND gm.status = 'active'
    )
  );

-- User can insert their own pending request
CREATE POLICY "group_members: self join request" ON group_members
  FOR INSERT WITH CHECK (user_id = auth.uid() AND status = 'pending_approval');

-- User can update their own row (e.g., leave group → status = 'left')
CREATE POLICY "group_members: self leave" ON group_members
  FOR UPDATE USING (user_id = auth.uid());

-- Active members can read the invite code for their group
CREATE POLICY "group_invites: select for active members" ON group_invites
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = group_invites.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Admins can manage invite codes
CREATE POLICY "group_invites: admin manage" ON group_invites
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = group_invites.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );

-- Anyone authenticated can read by code (for join flow)
CREATE POLICY "group_invites: select by code" ON group_invites
  FOR SELECT USING (auth.role() = 'authenticated');
-- Active members can read games in their group
CREATE POLICY "games: select for members" ON games
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = games.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Only admins (host/co_host) can create, update, delete games
CREATE POLICY "games: admin write" ON games
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = games.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );


-- Active members can read
CREATE POLICY "announcements: select for members" ON announcements
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = announcements.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Admins can insert, update, delete
CREATE POLICY "announcements: admin write" ON announcements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = announcements.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );

-- Active members can read cost items for games in their group
CREATE POLICY "game_cost_items: select for members" ON game_cost_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM games
      JOIN group_members ON group_members.group_id = games.group_id
      WHERE games.id = game_cost_items.game_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Payment owner can manage cost items
CREATE POLICY "game_cost_items: payment owner write" ON game_cost_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM games
      WHERE games.id = game_cost_items.game_id
        AND games.payment_owner_id = auth.uid()
    )
  );

-- Active members can read all RSVPs for games in their group
CREATE POLICY "rsvps: select for members" ON rsvps
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM games
      JOIN group_members ON group_members.group_id = games.group_id
      WHERE games.id = rsvps.game_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Players can insert/update their own RSVP
CREATE POLICY "rsvps: self write" ON rsvps
  FOR ALL USING (user_id = auth.uid());

-- Admins can update any RSVP in their group (e.g., manual waitlist promotion)
CREATE POLICY "rsvps: admin write" ON rsvps
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM games
      JOIN group_members ON group_members.group_id = games.group_id
      WHERE games.id = rsvps.game_id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );

-- Players can only see their own dues
CREATE POLICY "payment_dues: player select own" ON payment_dues
  FOR SELECT USING (player_id = auth.uid());

-- Payment owner can see all dues for games they own
CREATE POLICY "payment_dues: owner select" ON payment_dues
  FOR SELECT USING (payment_owner_id = auth.uid());

-- Players can update their own dues (submit UTR reference)
CREATE POLICY "payment_dues: player submit utr" ON payment_dues
  FOR UPDATE USING (
    player_id = auth.uid()
    AND status = 'unpaid'
  )
  WITH CHECK (
    status = 'pending_verification'
    AND utr_reference IS NOT NULL
  );

-- Payment owner can update due status (approve/reject/mark paid)
CREATE POLICY "payment_dues: owner verify" ON payment_dues
  FOR UPDATE USING (payment_owner_id = auth.uid());

-- Edge functions / service role can insert dues
-- (handled via service_role key in Edge Functions, bypasses RLS)
-- Active members can read completion records for their group's games
CREATE POLICY "game_completion: select for members" ON game_completion
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM games
      JOIN group_members ON group_members.group_id = games.group_id
      WHERE games.id = game_completion.game_id
        AND group_members.user_id = auth.uid()
        AND group_members.status = 'active'
    )
  );

-- Payment owner (game creator) can insert/update completion
CREATE POLICY "game_completion: owner write" ON game_completion
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM games
      WHERE games.id = game_completion.game_id
        AND games.payment_owner_id = auth.uid()
    )
  );

-- Admins can read audit logs for their group
CREATE POLICY "audit_logs: admin select" ON audit_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM group_members
      WHERE group_members.group_id = audit_logs.group_id
        AND group_members.user_id = auth.uid()
        AND group_members.role IN ('host', 'co_host')
        AND group_members.status = 'active'
    )
  );

-- Insert only via service_role (Edge Functions) — no direct client insert
-- Users can manage their own tokens
CREATE POLICY "notification_tokens: self manage" ON notification_tokens
  FOR ALL USING (user_id = auth.uid());