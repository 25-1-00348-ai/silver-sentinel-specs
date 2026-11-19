-- Silver Sentinel (Dasaka) - Supabase PostgreSQL schema, MVP
-- Version: v1.0.0 (full snapshot). Idempotent: safe to re-run.
-- Source: business-logic-v1.1.md, db-design-choices.md
--
-- Conventions (see db-design-choices.md):
--   * id    bigint identity: server-only, index/arrival order only, never synced.
--   * uuid  global identity, minted by the client/API. All relations use <parent>_uuid.
--   * No REFERENCES on *_uuid columns (offline-first, out-of-order sync).
--   * Soft delete via archived_at; uniqueness only on live rows.
--   * created_by is stamped by the server from the session, never accepted from clients.
--   * Clients never access the DB directly: RLS is enabled with no policies, so only the
--     API (service_role) can read/write. Do not add anon/authenticated policies.

BEGIN;

-- ---------------------------------------------------------------------------
-- Enums (idempotent)
-- ---------------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE public.user_role AS ENUM ('system_admin', 'admin', 'moderator', 'contributor');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.account_status AS ENUM ('active', 'suspended');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.report_type AS ENUM ('arrival', 'occupancy', 'fare');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.arrival_status AS ENUM ('arrived_now', 'delayed', 'not_coming');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.occupancy_level AS ENUM ('seats_available', 'standing_room_only', 'full');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.fare_class AS ENUM ('regular', 'discounted');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.report_status AS ENUM ('published', 'hidden');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.response_kind AS ENUM ('confirm', 'dispute', 'flag');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.confidence_level AS ENUM ('low', 'medium', 'high');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.value_source AS ENUM ('crowd', 'admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.day_type AS ENUM ('weekday', 'saturday', 'sunday_holiday');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.favorite_target AS ENUM ('route', 'stop');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.moderation_queue_reason AS ENUM ('flagged', 'disputed', 'low_trust');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE public.moderation_decision AS ENUM ('pending', 'kept', 'edited', 'hidden');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- Schema version tracking
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.schema_version (
  version     text PRIMARY KEY,
  kind        text NOT NULL CHECK (kind IN ('snapshot', 'migration')),
  applied_at  timestamptz NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------------
-- account: identity (Google Sign-In). Guests have no account.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.account (
  id                      bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid                    uuid NOT NULL UNIQUE,
  google_sub              text NOT NULL,                    -- Google subject id
  email                   text NOT NULL,
  display_name            text,
  role                    public.user_role NOT NULL DEFAULT 'contributor',
  status                  public.account_status NOT NULL DEFAULT 'active',
  suspension_reason       text,                             -- shown to the suspended user
  suspended_at            timestamptz,
  trust_weight            smallint NOT NULL DEFAULT 1 CHECK (trust_weight BETWEEN 0 AND 3),
  confirmed_report_count  integer NOT NULL DEFAULT 0,       -- toward the +1 trust bonus
  locale                  text NOT NULL DEFAULT 'en' CHECK (locale IN ('en', 'fil', 'ceb')),
  consented_at            timestamptz,                      -- consent screen accepted
  privacy_notice_version  text,
  deletion_requested_at   timestamptz,                      -- hard-delete within 30 days
  created_by              uuid,
  created_at              timestamptz,
  updated_at              timestamptz,
  archived_at             timestamptz,
  CONSTRAINT account_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_account_google_sub_live
  ON public.account (google_sub) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_account_email_live
  ON public.account (lower(email)) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_account_role   ON public.account (role);
CREATE INDEX IF NOT EXISTS idx_account_status ON public.account (status);
CREATE INDEX IF NOT EXISTS idx_account_deletion
  ON public.account (deletion_requested_at) WHERE deletion_requested_at IS NOT NULL;

-- ---------------------------------------------------------------------------
-- bus_type: admin-managed fixed list (e.g. Ordinary, Air-conditioned)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.bus_type (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE,
  name        text NOT NULL,
  rank        integer,
  created_by  uuid,
  created_at  timestamptz,
  updated_at  timestamptz,
  archived_at timestamptz,
  CONSTRAINT bus_type_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_bus_type_name_live
  ON public.bus_type (lower(name)) WHERE archived_at IS NULL;

-- ---------------------------------------------------------------------------
-- route: one row per direction (Ormoc->Baybay, Baybay->Ormoc)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.route (
  id               bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid             uuid NOT NULL UNIQUE,
  code             text NOT NULL,
  name             text NOT NULL,
  origin_name      text NOT NULL,
  destination_name text NOT NULL,
  is_active        boolean NOT NULL DEFAULT true,
  rank             integer,
  created_by       uuid,
  created_at       timestamptz,
  updated_at       timestamptz,
  archived_at      timestamptz,
  CONSTRAINT route_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_route_code_live
  ON public.route (lower(code)) WHERE archived_at IS NULL;

-- ---------------------------------------------------------------------------
-- stop: physical stop with coordinates (for the ~300 m proximity check).
-- Reporter coordinates are NEVER stored; only stop/route coordinates are.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.stop (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE,
  name        text NOT NULL,
  latitude    double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude   double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  created_by  uuid,
  created_at  timestamptz,
  updated_at  timestamptz,
  archived_at timestamptz,
  CONSTRAINT stop_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS idx_stop_name ON public.stop (lower(name));

-- ---------------------------------------------------------------------------
-- route_stop: link table / placement. rank = order of the stop on the route.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.route_stop (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE,
  route_uuid  uuid NOT NULL,
  stop_uuid   uuid NOT NULL,
  rank        integer NOT NULL,
  created_by  uuid,
  created_at  timestamptz,
  updated_at  timestamptz,
  archived_at timestamptz,
  CONSTRAINT route_stop_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_route_stop_live
  ON public.route_stop (route_uuid, stop_uuid) WHERE archived_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS idx_route_stop_rank_live
  ON public.route_stop (route_uuid, rank) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_route_stop_stop ON public.route_stop (stop_uuid);

-- ---------------------------------------------------------------------------
-- baseline_schedule: admin-seeded fallback schedule (departures at a stop)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.baseline_schedule (
  id            bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid          uuid NOT NULL UNIQUE,
  route_uuid    uuid NOT NULL,
  stop_uuid     uuid,                                       -- NULL = route origin
  bus_type_uuid uuid,                                       -- NULL = all bus types
  day_type      public.day_type NOT NULL DEFAULT 'weekday',
  departure_time time NOT NULL,
  created_by    uuid,
  created_at    timestamptz,
  updated_at    timestamptz,
  archived_at   timestamptz,
  CONSTRAINT baseline_schedule_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS idx_baseline_schedule_route
  ON public.baseline_schedule (route_uuid, stop_uuid, day_type);

-- ---------------------------------------------------------------------------
-- baseline_fare: admin-seeded known fares (fallback when no fresh fare report)
-- Amounts in PHP, numeric to avoid float error.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.baseline_fare (
  id                    bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid                  uuid NOT NULL UNIQUE,
  route_uuid            uuid NOT NULL,
  bus_type_uuid         uuid NOT NULL,
  origin_stop_uuid      uuid NOT NULL,
  destination_stop_uuid uuid NOT NULL,
  regular_amount        numeric(8,2) NOT NULL CHECK (regular_amount >= 0),
  discounted_amount     numeric(8,2) CHECK (discounted_amount >= 0),  -- student/senior/PWD
  created_by            uuid,
  created_at            timestamptz,
  updated_at            timestamptz,
  archived_at           timestamptz,
  CONSTRAINT baseline_fare_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_baseline_fare_live
  ON public.baseline_fare (route_uuid, bus_type_uuid, origin_stop_uuid, destination_stop_uuid)
  WHERE archived_at IS NULL;

-- ---------------------------------------------------------------------------
-- report: raw crowdsourced report. Deleted after 90 days (only aggregates kept).
-- No coordinates, no free text. account_uuid is for abuse control only and is
-- never returned to other users. reported_at is set by the SERVER on receipt.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.report (
  id                    bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid                  uuid NOT NULL UNIQUE,                 -- client-minted (offline queue idempotency)
  type                  public.report_type NOT NULL,
  route_uuid            uuid NOT NULL,
  stop_uuid             uuid,                                 -- NULL only for route-level fare
  bus_type_uuid         uuid NOT NULL,
  account_uuid          uuid NOT NULL,                        -- server-stamped (= created_by)
  arrival_status        public.arrival_status,
  occupancy_level       public.occupancy_level,
  fare_origin_stop_uuid      uuid,
  fare_destination_stop_uuid uuid,
  fare_amount           numeric(8,2) CHECK (fare_amount >= 0),
  fare_class            public.fare_class,
  location_verified     boolean NOT NULL DEFAULT false,       -- false = "location not verified" (picked stop)
  trust_weight          smallint NOT NULL DEFAULT 1 CHECK (trust_weight BETWEEN 0 AND 3), -- snapshot at report time
  status                public.report_status NOT NULL DEFAULT 'published',
  hidden_at             timestamptz,
  reported_at           timestamptz NOT NULL DEFAULT now(),   -- server receipt time
  created_by            uuid,
  created_at            timestamptz,
  updated_at            timestamptz,
  archived_at           timestamptz,
  CONSTRAINT report_pkey PRIMARY KEY (id),
  -- exactly the payload that matches the type
  CONSTRAINT report_payload_chk CHECK (
    (type = 'arrival'   AND arrival_status IS NOT NULL AND occupancy_level IS NULL AND fare_amount IS NULL)
 OR (type = 'occupancy' AND occupancy_level IS NOT NULL AND arrival_status IS NULL AND fare_amount IS NULL)
 OR (type = 'fare'      AND fare_amount IS NOT NULL AND fare_class IS NOT NULL
                        AND fare_origin_stop_uuid IS NOT NULL AND fare_destination_stop_uuid IS NOT NULL
                        AND arrival_status IS NULL AND occupancy_level IS NULL)
  )
);
CREATE INDEX IF NOT EXISTS idx_report_route_type_time
  ON public.report (route_uuid, type, reported_at DESC);
CREATE INDEX IF NOT EXISTS idx_report_stop_type_time
  ON public.report (stop_uuid, type, reported_at DESC);
-- rate limits: 1 per route/type/5 min, 30/day
CREATE INDEX IF NOT EXISTS idx_report_account_time
  ON public.report (account_uuid, reported_at DESC);
CREATE INDEX IF NOT EXISTS idx_report_account_route_type
  ON public.report (account_uuid, route_uuid, type, reported_at DESC);
-- 90-day retention purge
CREATE INDEX IF NOT EXISTS idx_report_reported_at ON public.report (reported_at);

-- ---------------------------------------------------------------------------
-- report_response: confirm ("Still true"), dispute ("Wrong"), flag
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.report_response (
  id           bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid         uuid NOT NULL UNIQUE,
  report_uuid  uuid NOT NULL,
  account_uuid uuid NOT NULL,                                 -- server-stamped
  kind         public.response_kind NOT NULL,
  trust_weight smallint NOT NULL DEFAULT 1 CHECK (trust_weight BETWEEN 0 AND 3),
  created_by   uuid,
  created_at   timestamptz,
  updated_at   timestamptz,
  archived_at  timestamptz,
  CONSTRAINT report_response_pkey PRIMARY KEY (id)
);
-- one live response of each kind per rider per report
CREATE UNIQUE INDEX IF NOT EXISTS idx_report_response_live
  ON public.report_response (report_uuid, account_uuid, kind) WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_report_response_account ON public.report_response (account_uuid);

-- ---------------------------------------------------------------------------
-- current_value: one current value per (route, stop, type, bus type).
-- Fares are per bus type; arrival/occupancy carry bus type as a label.
-- Denormalized read model; expires at the end of the freshness window
-- (occupancy 15 min, arrival 30 min, fare 30 days).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.current_value (
  id               bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid             uuid NOT NULL UNIQUE,
  type             public.report_type NOT NULL,
  route_uuid       uuid NOT NULL,
  stop_uuid        uuid,
  bus_type_uuid    uuid NOT NULL,
  -- value (matches report payload)
  arrival_status   public.arrival_status,
  occupancy_level  public.occupancy_level,
  fare_origin_stop_uuid      uuid,
  fare_destination_stop_uuid uuid,
  fare_regular_amount        numeric(8,2),
  fare_discounted_amount     numeric(8,2),
  -- quality
  confidence_score numeric(6,2) NOT NULL DEFAULT 0,           -- trust-weighted distinct riders
  confidence       public.confidence_level NOT NULL DEFAULT 'low',  -- low=Unconfirmed, medium/high=Verified
  source           public.value_source NOT NULL DEFAULT 'crowd',    -- admin always overrides
  source_report_uuid uuid,
  last_reported_at timestamptz NOT NULL,
  expires_at       timestamptz NOT NULL,
  created_by       uuid,
  created_at       timestamptz,
  updated_at       timestamptz,
  archived_at      timestamptz,
  CONSTRAINT current_value_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_current_value_live
  ON public.current_value (type, route_uuid, COALESCE(stop_uuid, '00000000-0000-0000-0000-000000000000'::uuid),
                           bus_type_uuid,
                           COALESCE(fare_origin_stop_uuid, '00000000-0000-0000-0000-000000000000'::uuid),
                           COALESCE(fare_destination_stop_uuid, '00000000-0000-0000-0000-000000000000'::uuid))
  WHERE archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_current_value_route ON public.current_value (route_uuid, type);
CREATE INDEX IF NOT EXISTS idx_current_value_stop  ON public.current_value (stop_uuid, type);

-- ---------------------------------------------------------------------------
-- moderation_item: queue (flagged, disputed by 2+, or low-trust contributor)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.moderation_item (
  id               bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid             uuid NOT NULL UNIQUE,
  report_uuid      uuid NOT NULL,
  reason           public.moderation_queue_reason NOT NULL,
  decision         public.moderation_decision NOT NULL DEFAULT 'pending',
  decided_by       uuid,                                      -- moderator account, server-stamped
  decided_at       timestamptz,
  due_at           timestamptz,                               -- 24 h target for flagged items
  created_by       uuid,
  created_at       timestamptz,
  updated_at       timestamptz,
  archived_at      timestamptz,
  CONSTRAINT moderation_item_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_moderation_item_open
  ON public.moderation_item (report_uuid, reason) WHERE decision = 'pending' AND archived_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_moderation_item_queue
  ON public.moderation_item (decision, due_at);

-- ---------------------------------------------------------------------------
-- favorite: saved routes / stops (Contributor+)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.favorite (
  id           bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid         uuid NOT NULL UNIQUE,
  account_uuid uuid NOT NULL,
  target_type  public.favorite_target NOT NULL,
  route_uuid   uuid,
  stop_uuid    uuid,
  created_by   uuid,
  created_at   timestamptz,
  updated_at   timestamptz,
  archived_at  timestamptz,
  CONSTRAINT favorite_pkey PRIMARY KEY (id),
  CONSTRAINT favorite_target_chk CHECK (
    (target_type = 'route' AND route_uuid IS NOT NULL AND stop_uuid IS NULL)
 OR (target_type = 'stop'  AND stop_uuid  IS NOT NULL AND route_uuid IS NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_favorite_live
  ON public.favorite (account_uuid, target_type,
                      COALESCE(route_uuid, stop_uuid))
  WHERE archived_at IS NULL;

-- ---------------------------------------------------------------------------
-- audit_log: append-only moderator/admin actions. Kept 1 year.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_log (
  id           bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid         uuid NOT NULL UNIQUE,
  actor_uuid   uuid NOT NULL,                                 -- server-stamped from session
  actor_role   public.user_role NOT NULL,
  action       text NOT NULL,                                 -- e.g. report.hide, account.suspend
  entity_type  text NOT NULL,
  entity_uuid  uuid,
  detail       jsonb,                                         -- before/after, reason; no personal data
  created_at   timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT audit_log_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS idx_audit_log_created ON public.audit_log (created_at);
CREATE INDEX IF NOT EXISTS idx_audit_log_entity  ON public.audit_log (entity_type, entity_uuid);
CREATE INDEX IF NOT EXISTS idx_audit_log_actor   ON public.audit_log (actor_uuid);

-- ---------------------------------------------------------------------------
-- app_setting: settings as rows (feature, name, value)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.app_setting (
  id          bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid        uuid NOT NULL UNIQUE,
  feature     text NOT NULL,
  name        text NOT NULL,
  value       text NOT NULL,
  created_by  uuid,
  created_at  timestamptz,
  updated_at  timestamptz,
  archived_at timestamptz,
  CONSTRAINT app_setting_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_app_setting_live
  ON public.app_setting (feature, name) WHERE archived_at IS NULL;

-- ---------------------------------------------------------------------------
-- analytics_daily: aggregates kept after raw reports are purged.
-- Only publish a row where report_count >= 5 (aggregation threshold).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.analytics_daily (
  id               bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  uuid             uuid NOT NULL UNIQUE,
  day              date NOT NULL,
  route_uuid       uuid,                                      -- NULL = system-wide
  metric           text NOT NULL CHECK (metric IN (
                     'daily_active_users', 'reports', 'fresh_route_share',
                     'confirmation_rate', 'hidden_report_rate')),
  value            numeric(12,4) NOT NULL,
  report_count     integer NOT NULL DEFAULT 0,
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT analytics_daily_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_analytics_daily_key
  ON public.analytics_daily (day, metric, COALESCE(route_uuid, '00000000-0000-0000-0000-000000000000'::uuid));

-- ---------------------------------------------------------------------------
-- Row Level Security: enabled everywhere, no policies => only service_role (the
-- Python API) can touch data. Clients never connect to the database directly.
-- ---------------------------------------------------------------------------
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'schema_version','account','bus_type','route','stop','route_stop','baseline_schedule',
    'baseline_fare','report','report_response','current_value','moderation_item','favorite',
    'audit_log','app_setting','analytics_daily']
  LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Record this snapshot
-- ---------------------------------------------------------------------------
INSERT INTO public.schema_version (version, kind) VALUES ('v1.0.0', 'snapshot')
ON CONFLICT (version) DO NOTHING;

COMMIT;
