/**
 * Database Types
 * Common types and interfaces for database entities
 * These types mirror the Prisma schema but can be extended with business logic
 */

// ============================================================================
// ENUMS
// ============================================================================

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
}

export enum UserRole {
  OWNER = 'OWNER',
  ADMIN = 'ADMIN',
  MEMBER = 'MEMBER',
  VIEWER = 'VIEWER',
}

export enum CalendarProvider {
  GOOGLE = 'GOOGLE',
  MICROSOFT = 'MICROSOFT',
  APPLE = 'APPLE',
  CUSTOM = 'CUSTOM',
}

export enum DayOfWeek {
  MONDAY = 'MONDAY',
  TUESDAY = 'TUESDAY',
  WEDNESDAY = 'WEDNESDAY',
  THURSDAY = 'THURSDAY',
  FRIDAY = 'FRIDAY',
  SATURDAY = 'SATURDAY',
  SUNDAY = 'SUNDAY',
}

export enum OverrideType {
  UNAVAILABLE = 'UNAVAILABLE',
  AVAILABLE = 'AVAILABLE',
}

export enum EventTypeKind {
  ONE_ON_ONE = 'ONE_ON_ONE',
  GROUP = 'GROUP',
  COLLECTIVE = 'COLLECTIVE',
  ROUND_ROBIN = 'ROUND_ROBIN',
}

export enum LocationType {
  PHONE = 'PHONE',
  IN_PERSON = 'IN_PERSON',
  ZOOM = 'ZOOM',
  GOOGLE_MEET = 'GOOGLE_MEET',
  MICROSOFT_TEAMS = 'MICROSOFT_TEAMS',
  CUSTOM = 'CUSTOM',
}

export enum BookingStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  RESCHEDULED = 'RESCHEDULED',
  CANCELED = 'CANCELED',
  NO_SHOW = 'NO_SHOW',
  COMPLETED = 'COMPLETED',
}

export enum QuestionType {
  SHORT_TEXT = 'SHORT_TEXT',
  LONG_TEXT = 'LONG_TEXT',
  SINGLE_SELECT = 'SINGLE_SELECT',
  MULTI_SELECT = 'MULTI_SELECT',
  PHONE = 'PHONE',
  EMAIL = 'EMAIL',
  NUMBER = 'NUMBER',
}

export enum RoutingOperator {
  EQUALS = 'EQUALS',
  NOT_EQUALS = 'NOT_EQUALS',
  CONTAINS = 'CONTAINS',
  GREATER_THAN = 'GREATER_THAN',
  LESS_THAN = 'LESS_THAN',
  IN = 'IN',
}

export enum AssignmentStrategy {
  ROTATE = 'ROTATE',
  WEIGHTED = 'WEIGHTED',
  LEAST_RECENT = 'LEAST_RECENT',
  PRIORITY = 'PRIORITY',
}

export enum WorkflowTrigger {
  BOOKING_CREATED = 'BOOKING_CREATED',
  BOOKING_RESCHEDULED = 'BOOKING_RESCHEDULED',
  BOOKING_CANCELED = 'BOOKING_CANCELED',
  BEFORE_MEETING = 'BEFORE_MEETING',
  AFTER_MEETING = 'AFTER_MEETING',
}

export enum WorkflowChannel {
  EMAIL = 'EMAIL',
  SMS = 'SMS',
  WEBHOOK = 'WEBHOOK',
}

export enum NotificationStatus {
  PENDING = 'PENDING',
  SENT = 'SENT',
  FAILED = 'FAILED',
  CANCELED = 'CANCELED',
}

export enum WebhookEvent {
  BOOKING_CREATED = 'BOOKING_CREATED',
  BOOKING_UPDATED = 'BOOKING_UPDATED',
  BOOKING_CANCELED = 'BOOKING_CANCELED',
  BOOKING_RESCHEDULED = 'BOOKING_RESCHEDULED',
  INVITEE_CREATED = 'INVITEE_CREATED',
  ROUTING_SUBMITTED = 'ROUTING_SUBMITTED',
}

export enum WebhookDeliveryStatus {
  PENDING = 'PENDING',
  SUCCESS = 'SUCCESS',
  FAILED = 'FAILED',
  RETRYING = 'RETRYING',
}

export enum AuditAction {
  CREATE = 'CREATE',
  UPDATE = 'UPDATE',
  DELETE = 'DELETE',
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  EXPORT = 'EXPORT',
  SHARE = 'SHARE',
}

export enum DeletionStatus {
  PENDING = 'PENDING',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
}

// ============================================================================
// BASE INTERFACES
// ============================================================================

/**
 * Base entity with common timestamp fields
 */
export interface BaseEntity {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Soft-deletable entity
 */
export interface SoftDeletableEntity extends BaseEntity {
  deletedAt: Date | null;
}

// ============================================================================
// PAGINATION
// ============================================================================

export interface PaginationParams {
  page?: number;
  limit?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

// ============================================================================
// QUERY FILTERS
// ============================================================================

export interface DateRangeFilter {
  from?: Date;
  to?: Date;
}

export interface BaseQueryFilter extends PaginationParams {
  search?: string;
  status?: string;
  createdAt?: DateRangeFilter;
  updatedAt?: DateRangeFilter;
}
