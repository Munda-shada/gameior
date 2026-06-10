CREATE TABLE group_invites (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id    uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  code        text NOT NULL UNIQUE,                     -- short alphanumeric code e.g. "X7K2P9"
  created_by  uuid NOT NULL REFERENCES profiles(id),
  created_at  timestamptz NOT NULL DEFAULT now(),

  UNIQUE (group_id)                                     -- one active code per group
);