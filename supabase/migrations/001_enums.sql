CREATE TYPE sport_type AS ENUM (
  'badminton', 'football', 'cricket', 'basketball',
  'tennis', 'volleyball', 'pickleball', 'other'
);

CREATE TYPE member_role AS ENUM ('host', 'co_host', 'player');

CREATE TYPE membership_status AS ENUM (
  'pending_approval', 'active', 'removed', 'left'
);

CREATE TYPE rsvp_status AS ENUM (
  'unanswered', 'yes', 'no', 'maybe', 'guest', 'waitlist'
);

CREATE TYPE payment_model AS ENUM ('prepaid', 'postpaid');

CREATE TYPE game_status AS ENUM (
  'upcoming', 'completed', 'cancelled'
);

CREATE TYPE due_status AS ENUM (
  'unpaid', 'pending_verification', 'paid', 'rejected'
);

CREATE TYPE skill_level AS ENUM (
  'all', 'beginner', 'intermediate', 'advanced'
);

CREATE TYPE notification_delivery AS ENUM (
  'immediate', 'daily_digest', 'quiet_hours'
);

CREATE TYPE audit_action AS ENUM (
  'member_joined', 'member_left', 'member_removed',
  'role_promoted', 'role_demoted', 'ownership_transferred',
  'join_request_accepted', 'join_request_rejected'
);