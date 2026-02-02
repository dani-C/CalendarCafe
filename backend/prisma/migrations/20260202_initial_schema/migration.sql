-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');
CREATE TYPE "UserRole" AS ENUM ('OWNER', 'ADMIN', 'MEMBER', 'VIEWER');
CREATE TYPE "CalendarProvider" AS ENUM ('GOOGLE', 'MICROSOFT', 'APPLE', 'CUSTOM');
CREATE TYPE "DayOfWeek" AS ENUM ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY');
CREATE TYPE "OverrideType" AS ENUM ('UNAVAILABLE', 'AVAILABLE');
CREATE TYPE "EventTypeKind" AS ENUM ('ONE_ON_ONE', 'GROUP', 'COLLECTIVE', 'ROUND_ROBIN');
CREATE TYPE "LocationType" AS ENUM ('PHONE', 'IN_PERSON', 'ZOOM', 'GOOGLE_MEET', 'MICROSOFT_TEAMS', 'CUSTOM');
CREATE TYPE "BookingStatus" AS ENUM ('PENDING', 'CONFIRMED', 'RESCHEDULED', 'CANCELED', 'NO_SHOW', 'COMPLETED');
CREATE TYPE "QuestionType" AS ENUM ('SHORT_TEXT', 'LONG_TEXT', 'SINGLE_SELECT', 'MULTI_SELECT', 'PHONE', 'EMAIL', 'NUMBER');
CREATE TYPE "RoutingOperator" AS ENUM ('EQUALS', 'NOT_EQUALS', 'CONTAINS', 'GREATER_THAN', 'LESS_THAN', 'IN');
CREATE TYPE "AssignmentStrategy" AS ENUM ('ROTATE', 'WEIGHTED', 'LEAST_RECENT', 'PRIORITY');
CREATE TYPE "WorkflowTrigger" AS ENUM ('BOOKING_CREATED', 'BOOKING_RESCHEDULED', 'BOOKING_CANCELED', 'BEFORE_MEETING', 'AFTER_MEETING');
CREATE TYPE "WorkflowChannel" AS ENUM ('EMAIL', 'SMS', 'WEBHOOK');
CREATE TYPE "NotificationStatus" AS ENUM ('PENDING', 'SENT', 'FAILED', 'CANCELED');
CREATE TYPE "WebhookEvent" AS ENUM ('BOOKING_CREATED', 'BOOKING_UPDATED', 'BOOKING_CANCELED', 'BOOKING_RESCHEDULED', 'INVITEE_CREATED', 'ROUTING_SUBMITTED');
CREATE TYPE "WebhookDeliveryStatus" AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'RETRYING');
CREATE TYPE "AuditAction" AS ENUM ('CREATE', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'EXPORT', 'SHARE');
CREATE TYPE "DeletionStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'FAILED');

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "domain" VARCHAR(255),
    "logoUrl" TEXT,
    "timezone" VARCHAR(100) NOT NULL DEFAULT 'UTC',
    "brandColor" VARCHAR(7),
    "ssoEnabled" BOOLEAN NOT NULL DEFAULT false,
    "scimEnabled" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "email" VARCHAR(255) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "avatar" TEXT,
    "timezone" VARCHAR(100) NOT NULL DEFAULT 'UTC',
    "locale" VARCHAR(10) NOT NULL DEFAULT 'en',
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "passwordHash" VARCHAR(255),
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "lastLoginAt" TIMESTAMPTZ(3),
    "organizationId" UUID NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "teams" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "organizationId" UUID NOT NULL,

    CONSTRAINT "teams_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "team_members" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "role" "UserRole" NOT NULL DEFAULT 'MEMBER',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "userId" UUID NOT NULL,
    "teamId" UUID NOT NULL,

    CONSTRAINT "team_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "calendar_connections" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "provider" "CalendarProvider" NOT NULL,
    "providerAccountId" VARCHAR(255) NOT NULL,
    "accessToken" TEXT NOT NULL,
    "refreshToken" TEXT,
    "expiresAt" TIMESTAMPTZ(3),
    "calendarId" VARCHAR(255) NOT NULL,
    "calendarName" VARCHAR(255) NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "lastSyncAt" TIMESTAMPTZ(3),
    "syncToken" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "userId" UUID NOT NULL,

    CONSTRAINT "calendar_connections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "availability_schedules" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "timezone" VARCHAR(100) NOT NULL,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "userId" UUID NOT NULL,

    CONSTRAINT "availability_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "availability_slots" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "dayOfWeek" "DayOfWeek" NOT NULL,
    "startTime" VARCHAR(5) NOT NULL,
    "endTime" VARCHAR(5) NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "scheduleId" UUID NOT NULL,

    CONSTRAINT "availability_slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "availability_overrides" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "type" "OverrideType" NOT NULL,
    "date" DATE NOT NULL,
    "startTime" VARCHAR(5),
    "endTime" VARCHAR(5),
    "reason" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "scheduleId" UUID NOT NULL,

    CONSTRAINT "availability_overrides_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_types" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "slug" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "kind" "EventTypeKind" NOT NULL DEFAULT 'ONE_ON_ONE',
    "duration" INTEGER NOT NULL,
    "bufferBefore" INTEGER NOT NULL DEFAULT 0,
    "bufferAfter" INTEGER NOT NULL DEFAULT 0,
    "minNotice" INTEGER NOT NULL DEFAULT 0,
    "maxBookingsPerDay" INTEGER,
    "maxBookingsPerWeek" INTEGER,
    "locationType" "LocationType" NOT NULL,
    "locationValue" TEXT,
    "capacity" INTEGER,
    "minCapacity" INTEGER,
    "color" VARCHAR(7),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "userId" UUID NOT NULL,
    "teamId" UUID,
    "scheduleId" UUID,
    "roundRobinPoolId" UUID,

    CONSTRAINT "event_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bookings" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "status" "BookingStatus" NOT NULL DEFAULT 'CONFIRMED',
    "startTime" TIMESTAMPTZ(3) NOT NULL,
    "endTime" TIMESTAMPTZ(3) NOT NULL,
    "timezone" VARCHAR(100) NOT NULL,
    "location" TEXT NOT NULL,
    "canceledAt" TIMESTAMPTZ(3),
    "cancelReason" TEXT,
    "canceledBy" VARCHAR(50),
    "noShowMarkedAt" TIMESTAMPTZ(3),
    "calendarEventId" VARCHAR(255),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "eventTypeId" UUID NOT NULL,
    "hostId" UUID NOT NULL,
    "inviteeId" UUID NOT NULL,

    CONSTRAINT "bookings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "invitees" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "email" VARCHAR(255) NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(50),
    "timezone" VARCHAR(100) NOT NULL,
    "notes" TEXT,
    "utmSource" VARCHAR(255),
    "utmMedium" VARCHAR(255),
    "utmCampaign" VARCHAR(255),
    "referrer" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,

    CONSTRAINT "invitees_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "questions" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "label" VARCHAR(500) NOT NULL,
    "type" "QuestionType" NOT NULL,
    "required" BOOLEAN NOT NULL DEFAULT false,
    "placeholder" VARCHAR(255),
    "options" TEXT[],
    "position" INTEGER NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "eventTypeId" UUID,
    "routingFormId" UUID,

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "answers" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "value" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "questionId" UUID NOT NULL,
    "bookingId" UUID,
    "routingSubmissionId" UUID,

    CONSTRAINT "answers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "routing_forms" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),

    CONSTRAINT "routing_forms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "routing_rules" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "position" INTEGER NOT NULL,
    "questionLabel" VARCHAR(500) NOT NULL,
    "operator" "RoutingOperator" NOT NULL,
    "value" TEXT NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "routingFormId" UUID NOT NULL,
    "eventTypeId" UUID NOT NULL,

    CONSTRAINT "routing_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "routing_submissions" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "matchedEventTypeId" UUID,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "routingFormId" UUID NOT NULL,

    CONSTRAINT "routing_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "round_robin_pools" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "strategy" "AssignmentStrategy" NOT NULL DEFAULT 'ROTATE',
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "teamId" UUID NOT NULL,

    CONSTRAINT "round_robin_pools_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "round_robin_assignments" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "weight" INTEGER NOT NULL DEFAULT 1,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "lastAssignedAt" TIMESTAMPTZ(3),
    "assignmentCount" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "poolId" UUID NOT NULL,
    "userId" UUID NOT NULL,

    CONSTRAINT "round_robin_assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "workflows" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "name" VARCHAR(255) NOT NULL,
    "trigger" "WorkflowTrigger" NOT NULL,
    "channel" "WorkflowChannel" NOT NULL,
    "minutesBefore" INTEGER,
    "subject" VARCHAR(500),
    "body" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "userId" UUID NOT NULL,
    "eventTypeId" UUID,

    CONSTRAINT "workflows_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notification_logs" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "status" "NotificationStatus" NOT NULL DEFAULT 'PENDING',
    "channel" "WorkflowChannel" NOT NULL,
    "recipient" VARCHAR(255) NOT NULL,
    "subject" VARCHAR(500),
    "body" TEXT NOT NULL,
    "sentAt" TIMESTAMPTZ(3),
    "failedAt" TIMESTAMPTZ(3),
    "errorMessage" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "workflowId" UUID NOT NULL,
    "bookingId" UUID NOT NULL,

    CONSTRAINT "notification_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_subscriptions" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "url" TEXT NOT NULL,
    "events" "WebhookEvent"[],
    "secret" VARCHAR(255) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deletedAt" TIMESTAMPTZ(3),
    "organizationId" UUID NOT NULL,

    CONSTRAINT "webhook_subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "webhook_deliveries" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "event" "WebhookEvent" NOT NULL,
    "status" "WebhookDeliveryStatus" NOT NULL DEFAULT 'PENDING',
    "payload" JSONB NOT NULL,
    "headers" JSONB,
    "statusCode" INTEGER,
    "response" TEXT,
    "attemptCount" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 3,
    "nextRetryAt" TIMESTAMPTZ(3),
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "deliveredAt" TIMESTAMPTZ(3),
    "subscriptionId" UUID NOT NULL,
    "bookingId" UUID,

    CONSTRAINT "webhook_deliveries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "action" "AuditAction" NOT NULL,
    "entityType" VARCHAR(100) NOT NULL,
    "entityId" UUID NOT NULL,
    "oldValues" JSONB,
    "newValues" JSONB,
    "ipAddress" VARCHAR(45),
    "userAgent" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" UUID NOT NULL,
    "organizationId" UUID NOT NULL,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "retention_policies" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "entityType" VARCHAR(100) NOT NULL,
    "retentionDays" INTEGER NOT NULL,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "organizationId" UUID NOT NULL,

    CONSTRAINT "retention_policies_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "deletion_requests" (
    "id" UUID NOT NULL DEFAULT uuid_generate_v4(),
    "entityType" VARCHAR(100) NOT NULL,
    "entityId" UUID NOT NULL,
    "status" "DeletionStatus" NOT NULL DEFAULT 'PENDING',
    "deletedAt" TIMESTAMPTZ(3),
    "failedAt" TIMESTAMPTZ(3),
    "errorMessage" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ(3) NOT NULL,
    "policyId" UUID NOT NULL,

    CONSTRAINT "deletion_requests_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "organizations_slug_key" ON "organizations"("slug");
CREATE INDEX "organizations_slug_idx" ON "organizations"("slug");
CREATE INDEX "organizations_deletedAt_idx" ON "organizations"("deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");
CREATE INDEX "users_organizationId_idx" ON "users"("organizationId");
CREATE INDEX "users_email_idx" ON "users"("email");
CREATE INDEX "users_status_idx" ON "users"("status");
CREATE INDEX "users_deletedAt_idx" ON "users"("deletedAt");

-- CreateIndex
CREATE INDEX "teams_organizationId_idx" ON "teams"("organizationId");
CREATE INDEX "teams_deletedAt_idx" ON "teams"("deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "team_members_userId_teamId_key" ON "team_members"("userId", "teamId");
CREATE INDEX "team_members_userId_idx" ON "team_members"("userId");
CREATE INDEX "team_members_teamId_idx" ON "team_members"("teamId");

-- CreateIndex
CREATE UNIQUE INDEX "calendar_connections_userId_provider_providerAccountId_key" ON "calendar_connections"("userId", "provider", "providerAccountId");
CREATE INDEX "calendar_connections_userId_idx" ON "calendar_connections"("userId");
CREATE INDEX "calendar_connections_provider_idx" ON "calendar_connections"("provider");
CREATE INDEX "calendar_connections_deletedAt_idx" ON "calendar_connections"("deletedAt");

-- CreateIndex
CREATE INDEX "availability_schedules_userId_idx" ON "availability_schedules"("userId");
CREATE INDEX "availability_schedules_isDefault_idx" ON "availability_schedules"("isDefault");
CREATE INDEX "availability_schedules_deletedAt_idx" ON "availability_schedules"("deletedAt");

-- CreateIndex
CREATE INDEX "availability_slots_scheduleId_idx" ON "availability_slots"("scheduleId");
CREATE INDEX "availability_slots_dayOfWeek_idx" ON "availability_slots"("dayOfWeek");

-- CreateIndex
CREATE INDEX "availability_overrides_scheduleId_idx" ON "availability_overrides"("scheduleId");
CREATE INDEX "availability_overrides_date_idx" ON "availability_overrides"("date");

-- CreateIndex
CREATE UNIQUE INDEX "event_types_userId_slug_key" ON "event_types"("userId", "slug");
CREATE INDEX "event_types_userId_idx" ON "event_types"("userId");
CREATE INDEX "event_types_teamId_idx" ON "event_types"("teamId");
CREATE INDEX "event_types_slug_idx" ON "event_types"("slug");
CREATE INDEX "event_types_isActive_idx" ON "event_types"("isActive");
CREATE INDEX "event_types_kind_idx" ON "event_types"("kind");
CREATE INDEX "event_types_deletedAt_idx" ON "event_types"("deletedAt");

-- CreateIndex
CREATE INDEX "bookings_eventTypeId_idx" ON "bookings"("eventTypeId");
CREATE INDEX "bookings_hostId_idx" ON "bookings"("hostId");
CREATE INDEX "bookings_inviteeId_idx" ON "bookings"("inviteeId");
CREATE INDEX "bookings_status_idx" ON "bookings"("status");
CREATE INDEX "bookings_startTime_idx" ON "bookings"("startTime");
CREATE INDEX "bookings_createdAt_idx" ON "bookings"("createdAt");

-- CreateIndex
CREATE INDEX "invitees_email_idx" ON "invitees"("email");
CREATE INDEX "invitees_createdAt_idx" ON "invitees"("createdAt");

-- CreateIndex
CREATE INDEX "questions_eventTypeId_idx" ON "questions"("eventTypeId");
CREATE INDEX "questions_routingFormId_idx" ON "questions"("routingFormId");
CREATE INDEX "questions_position_idx" ON "questions"("position");

-- CreateIndex
CREATE INDEX "answers_questionId_idx" ON "answers"("questionId");
CREATE INDEX "answers_bookingId_idx" ON "answers"("bookingId");
CREATE INDEX "answers_routingSubmissionId_idx" ON "answers"("routingSubmissionId");

-- CreateIndex
CREATE INDEX "routing_forms_deletedAt_idx" ON "routing_forms"("deletedAt");

-- CreateIndex
CREATE INDEX "routing_rules_routingFormId_idx" ON "routing_rules"("routingFormId");
CREATE INDEX "routing_rules_eventTypeId_idx" ON "routing_rules"("eventTypeId");
CREATE INDEX "routing_rules_position_idx" ON "routing_rules"("position");

-- CreateIndex
CREATE INDEX "routing_submissions_routingFormId_idx" ON "routing_submissions"("routingFormId");
CREATE INDEX "routing_submissions_matchedEventTypeId_idx" ON "routing_submissions"("matchedEventTypeId");
CREATE INDEX "routing_submissions_createdAt_idx" ON "routing_submissions"("createdAt");

-- CreateIndex
CREATE INDEX "round_robin_pools_teamId_idx" ON "round_robin_pools"("teamId");
CREATE INDEX "round_robin_pools_deletedAt_idx" ON "round_robin_pools"("deletedAt");

-- CreateIndex
CREATE UNIQUE INDEX "round_robin_assignments_poolId_userId_key" ON "round_robin_assignments"("poolId", "userId");
CREATE INDEX "round_robin_assignments_poolId_idx" ON "round_robin_assignments"("poolId");
CREATE INDEX "round_robin_assignments_userId_idx" ON "round_robin_assignments"("userId");

-- CreateIndex
CREATE INDEX "workflows_userId_idx" ON "workflows"("userId");
CREATE INDEX "workflows_eventTypeId_idx" ON "workflows"("eventTypeId");
CREATE INDEX "workflows_trigger_idx" ON "workflows"("trigger");
CREATE INDEX "workflows_isActive_idx" ON "workflows"("isActive");
CREATE INDEX "workflows_deletedAt_idx" ON "workflows"("deletedAt");

-- CreateIndex
CREATE INDEX "notification_logs_workflowId_idx" ON "notification_logs"("workflowId");
CREATE INDEX "notification_logs_bookingId_idx" ON "notification_logs"("bookingId");
CREATE INDEX "notification_logs_status_idx" ON "notification_logs"("status");
CREATE INDEX "notification_logs_createdAt_idx" ON "notification_logs"("createdAt");

-- CreateIndex
CREATE INDEX "webhook_subscriptions_organizationId_idx" ON "webhook_subscriptions"("organizationId");
CREATE INDEX "webhook_subscriptions_isActive_idx" ON "webhook_subscriptions"("isActive");
CREATE INDEX "webhook_subscriptions_deletedAt_idx" ON "webhook_subscriptions"("deletedAt");

-- CreateIndex
CREATE INDEX "webhook_deliveries_subscriptionId_idx" ON "webhook_deliveries"("subscriptionId");
CREATE INDEX "webhook_deliveries_bookingId_idx" ON "webhook_deliveries"("bookingId");
CREATE INDEX "webhook_deliveries_status_idx" ON "webhook_deliveries"("status");
CREATE INDEX "webhook_deliveries_nextRetryAt_idx" ON "webhook_deliveries"("nextRetryAt");
CREATE INDEX "webhook_deliveries_createdAt_idx" ON "webhook_deliveries"("createdAt");

-- CreateIndex
CREATE INDEX "audit_logs_userId_idx" ON "audit_logs"("userId");
CREATE INDEX "audit_logs_organizationId_idx" ON "audit_logs"("organizationId");
CREATE INDEX "audit_logs_entityType_entityId_idx" ON "audit_logs"("entityType", "entityId");
CREATE INDEX "audit_logs_action_idx" ON "audit_logs"("action");
CREATE INDEX "audit_logs_createdAt_idx" ON "audit_logs"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "retention_policies_organizationId_entityType_key" ON "retention_policies"("organizationId", "entityType");
CREATE INDEX "retention_policies_organizationId_idx" ON "retention_policies"("organizationId");

-- CreateIndex
CREATE INDEX "deletion_requests_policyId_idx" ON "deletion_requests"("policyId");
CREATE INDEX "deletion_requests_status_idx" ON "deletion_requests"("status");
CREATE INDEX "deletion_requests_createdAt_idx" ON "deletion_requests"("createdAt");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "teams" ADD CONSTRAINT "teams_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_members" ADD CONSTRAINT "team_members_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "team_members" ADD CONSTRAINT "team_members_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "calendar_connections" ADD CONSTRAINT "calendar_connections_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "availability_schedules" ADD CONSTRAINT "availability_schedules_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "availability_slots" ADD CONSTRAINT "availability_slots_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "availability_schedules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "availability_overrides" ADD CONSTRAINT "availability_overrides_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "availability_schedules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_types" ADD CONSTRAINT "event_types_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_types" ADD CONSTRAINT "event_types_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_types" ADD CONSTRAINT "event_types_scheduleId_fkey" FOREIGN KEY ("scheduleId") REFERENCES "availability_schedules"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_types" ADD CONSTRAINT "event_types_roundRobinPoolId_fkey" FOREIGN KEY ("roundRobinPoolId") REFERENCES "round_robin_pools"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES "event_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_hostId_fkey" FOREIGN KEY ("hostId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bookings" ADD CONSTRAINT "bookings_inviteeId_fkey" FOREIGN KEY ("inviteeId") REFERENCES "invitees"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES "event_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_routingFormId_fkey" FOREIGN KEY ("routingFormId") REFERENCES "routing_forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_routingSubmissionId_fkey" FOREIGN KEY ("routingSubmissionId") REFERENCES "routing_submissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_routingFormId_fkey" FOREIGN KEY ("routingFormId") REFERENCES "routing_forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "routing_rules" ADD CONSTRAINT "routing_rules_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES "event_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "routing_submissions" ADD CONSTRAINT "routing_submissions_routingFormId_fkey" FOREIGN KEY ("routingFormId") REFERENCES "routing_forms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "round_robin_pools" ADD CONSTRAINT "round_robin_pools_teamId_fkey" FOREIGN KEY ("teamId") REFERENCES "teams"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "round_robin_assignments" ADD CONSTRAINT "round_robin_assignments_poolId_fkey" FOREIGN KEY ("poolId") REFERENCES "round_robin_pools"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "round_robin_assignments" ADD CONSTRAINT "round_robin_assignments_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workflows" ADD CONSTRAINT "workflows_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "workflows" ADD CONSTRAINT "workflows_eventTypeId_fkey" FOREIGN KEY ("eventTypeId") REFERENCES "event_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_logs" ADD CONSTRAINT "notification_logs_workflowId_fkey" FOREIGN KEY ("workflowId") REFERENCES "workflows"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notification_logs" ADD CONSTRAINT "notification_logs_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "webhook_subscriptions" ADD CONSTRAINT "webhook_subscriptions_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "webhook_deliveries" ADD CONSTRAINT "webhook_deliveries_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "webhook_subscriptions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "webhook_deliveries" ADD CONSTRAINT "webhook_deliveries_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "retention_policies" ADD CONSTRAINT "retention_policies_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "deletion_requests" ADD CONSTRAINT "deletion_requests_policyId_fkey" FOREIGN KEY ("policyId") REFERENCES "retention_policies"("id") ON DELETE CASCADE ON UPDATE CASCADE;
