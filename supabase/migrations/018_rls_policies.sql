-- Users can read their own profile
DROP POLICY IF EXISTS "profiles: select own" ON profiles;
CREATE POLICY "profiles: select own" ON profiles
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "profiles: update own" ON profiles;
CREATE POLICY "profiles: update own" ON profiles
  FOR UPDATE USING (auth.uid() = id);

-- Profile is readable by any authenticated user (for member lists, rosters)
DROP POLICY IF EXISTS "profiles: select any authenticated" ON profiles;
CREATE POLICY "profiles: select any authenticated" ON profiles
  FOR SELECT USING (auth.role() = 'authenticated');

-- Users can insert their own profile
DROP POLICY IF EXISTS "profiles: insert own" ON profiles;
CREATE POLICY "profiles: insert own" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);


-- Users can insert a new group (they become the host)
DROP POLICY IF EXISTS "groups: insert own" ON groups;
CREATE POLICY "groups: insert own" ON groups
  FOR INSERT WITH CHECK (auth.uid() = host_id);

-- Circuit breaker function to prevent Postgres from detecting a circular RLS dependency
CREATE OR REPLACE FUNCTION public.check_is_group_host(chk_group_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM groups
    WHERE id = chk_group_id AND host_id = auth.uid()
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_group_member(chk_group_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = chk_group_id AND user_id = auth.uid() AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION public.is_group_admin(chk_group_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM group_members
    WHERE group_id = chk_group_id AND user_id = auth.uid() AND role IN ('host', 'co_host') AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER SET search_path = public;

-- Any active member can read the group
DROP POLICY IF EXISTS "groups: select for active members" ON groups;
CREATE POLICY "groups: select for active members" ON groups
  FOR SELECT USING (
    host_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM group_members 
      WHERE group_members.group_id = groups.id AND group_members.user_id = auth.uid()
    )
  );

-- Only host or co_host can update group settings
DROP POLICY IF EXISTS "groups: update for admins" ON groups;
CREATE POLICY "groups: update for admins" ON groups
  FOR UPDATE USING (public.is_group_admin(id));

-- Only host can delete
DROP POLICY IF EXISTS "groups: delete for host" ON groups;
CREATE POLICY "groups: delete for host" ON groups
  FOR DELETE USING (host_id = auth.uid());

-- Users can always read their own memberships (crucial to load their pending statuses)
DROP POLICY IF EXISTS "group_members: select own" ON group_members;
CREATE POLICY "group_members: select own" ON group_members
  FOR SELECT USING (user_id = auth.uid());

-- Active members can see all members in their group
DROP POLICY IF EXISTS "group_members: select for active members" ON group_members;
CREATE POLICY "group_members: select for active members" ON group_members
  FOR SELECT USING (public.is_group_member(group_id));

-- Admins can insert (approve join requests) and update roles/status
DROP POLICY IF EXISTS "group_members: admin write" ON group_members;
CREATE POLICY "group_members: admin write" ON group_members
  FOR ALL USING (public.is_group_admin(group_id));

-- Allow the group host to insert the initial active member record for themselves
DROP POLICY IF EXISTS "group_members: host self insert" ON group_members;
CREATE POLICY "group_members: host self insert" ON group_members
  FOR INSERT WITH CHECK (public.check_is_group_host(group_id) AND user_id = auth.uid());

-- User can insert their own pending request (Revoked: joins must go through join_group Edge Function)
DROP POLICY IF EXISTS "group_members: self join request" ON group_members;

-- User can update their own row (e.g., leave group → status = 'left')
DROP POLICY IF EXISTS "group_members: self leave" ON group_members;
CREATE POLICY "group_members: self leave" ON group_members
  FOR UPDATE USING (user_id = auth.uid());

-- Active members can read the invite code for their group
DROP POLICY IF EXISTS "group_invites: select for active members" ON group_invites;
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
DROP POLICY IF EXISTS "group_invites: admin manage" ON group_invites;
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

-- Anyone authenticated can read by code (Revoked: code lookup is locked to service_role in join_group Edge Function)
DROP POLICY IF EXISTS "group_invites: select by code" ON group_invites;

-- Active members can read games in their group
DROP POLICY IF EXISTS "games: select for members" ON games;
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
DROP POLICY IF EXISTS "games: admin write" ON games;
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
DROP POLICY IF EXISTS "announcements: select for members" ON announcements;
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
DROP POLICY IF EXISTS "announcements: admin write" ON announcements;
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
DROP POLICY IF EXISTS "game_cost_items: select for members" ON game_cost_items;
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
DROP POLICY IF EXISTS "game_cost_items: payment owner write" ON game_cost_items;
CREATE POLICY "game_cost_items: payment owner write" ON game_cost_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM games
      WHERE games.id = game_cost_items.game_id
        AND games.payment_owner_id = auth.uid()
    )
  );

-- Active members can read all RSVPs for games in their group
DROP POLICY IF EXISTS "rsvps: select for members" ON rsvps;
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

-- Players can insert/update their own RSVP (Revoked: must use rsvp_update edge function)
DROP POLICY IF EXISTS "rsvps: self write" ON rsvps;

-- Admins can update any RSVP in their group (e.g., manual waitlist promotion)
DROP POLICY IF EXISTS "rsvps: admin write" ON rsvps;
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
DROP POLICY IF EXISTS "payment_dues: player select own" ON payment_dues;
CREATE POLICY "payment_dues: player select own" ON payment_dues
  FOR SELECT USING (player_id = auth.uid());

-- Payment owner can see all dues for games they own
DROP POLICY IF EXISTS "payment_dues: owner select" ON payment_dues;
CREATE POLICY "payment_dues: owner select" ON payment_dues
  FOR SELECT USING (payment_owner_id = auth.uid());

-- Players can update their own dues (submit UTR reference)
DROP POLICY IF EXISTS "payment_dues: player submit utr" ON payment_dues;
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
DROP POLICY IF EXISTS "payment_dues: owner verify" ON payment_dues;
CREATE POLICY "payment_dues: owner verify" ON payment_dues
  FOR UPDATE USING (payment_owner_id = auth.uid());

-- Edge functions / service role can insert dues
-- (handled via service_role key in Edge Functions, bypasses RLS)

-- Active members can read completion records for their group's games
DROP POLICY IF EXISTS "game_completion: select for members" ON game_completion;
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
DROP POLICY IF EXISTS "game_completion: owner write" ON game_completion;
CREATE POLICY "game_completion: owner write" ON game_completion
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM games
      WHERE games.id = game_completion.game_id
        AND games.payment_owner_id = auth.uid()
    )
  );

-- Admins can read audit logs for their group
DROP POLICY IF EXISTS "audit_logs: admin select" ON audit_logs;
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
DROP POLICY IF EXISTS "notification_tokens: self manage" ON notification_tokens;
CREATE POLICY "notification_tokens: self manage" ON notification_tokens
  FOR ALL USING (user_id = auth.uid());