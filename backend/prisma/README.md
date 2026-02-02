# Database Documentation

This document provides instructions for setting up and managing the CalendarCafe database using Prisma and PostgreSQL.

## Overview

The project uses:
- **Database**: PostgreSQL (recommended: Neon Serverless Postgres or local PostgreSQL)
- **ORM**: Prisma 7.x
- **Schema**: Comprehensive scheduling platform schema with 20+ tables

## Prerequisites

1. **PostgreSQL Database**: Set up a PostgreSQL database using one of these options:
   - [Neon](https://neon.tech) (Recommended - Serverless PostgreSQL)
   - Local PostgreSQL installation
   - Docker PostgreSQL container

2. **Node.js** 20+ installed

## Database Setup

### 1. Configure Database URL

Update the `.env` file with your PostgreSQL connection string:

```env
DATABASE_URL="postgresql://username:password@host:port/database?schema=public"
```

**Examples:**

**Neon (Recommended):**
```env
DATABASE_URL="postgresql://user:password@ep-example-123456.us-east-2.aws.neon.tech/calendarcafe?sslmode=require"
```

**Local PostgreSQL:**
```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/calendarcafe"
```

**Docker:**
```env
DATABASE_URL="postgresql://postgres:password@localhost:5432/calendarcafe"
```

### 2. Generate Prisma Client

Generate the Prisma Client to access your database:

```bash
npx prisma generate
```

### 3. Run Migrations

Apply the database schema to your database:

```bash
npx prisma migrate deploy
```

Or for development (creates migration if needed):

```bash
npx prisma migrate dev
```

## Schema Overview

The database schema includes the following main entities:

### Core Entities
- **Organizations**: Multi-tenant organization management
- **Users**: User accounts with authentication
- **Teams**: Team collaboration structure
- **TeamMembers**: User-team relationships with roles

### Calendar & Availability
- **CalendarConnections**: Integration with Google/Microsoft/Apple calendars
- **AvailabilitySchedules**: User availability rules
- **AvailabilitySlots**: Weekly time slots
- **AvailabilityOverrides**: Date-specific exceptions

### Event Types & Bookings
- **EventTypes**: Meeting templates (1:1, group, round robin, collective)
- **Bookings**: Scheduled meetings with status tracking
- **Invitees**: External booking participants

### Questions & Routing
- **Questions**: Booking form fields
- **Answers**: User responses
- **RoutingForms**: Intake forms for smart routing
- **RoutingRules**: Conditional routing logic
- **RoutingSubmissions**: Form submission records

### Team Scheduling
- **RoundRobinPools**: Host assignment pools
- **RoundRobinAssignments**: Pool member assignments with weights

### Automation
- **Workflows**: Email/SMS/webhook automation
- **NotificationLogs**: Notification delivery tracking
- **WebhookSubscriptions**: External webhook integrations
- **WebhookDeliveries**: Webhook delivery logs

### Compliance & Audit
- **AuditLogs**: Admin action tracking
- **RetentionPolicies**: Data retention rules
- **DeletionRequests**: Scheduled data deletion

## Common Operations

### View Database in Prisma Studio

```bash
npx prisma studio
```

This opens a GUI to view and edit your database at http://localhost:5555

### Reset Database (Development Only)

**WARNING**: This will delete all data!

```bash
npx prisma migrate reset
```

### Create New Migration

After modifying `schema.prisma`:

```bash
npx prisma migrate dev --name description_of_change
```

### Format Schema

```bash
npx prisma format
```

## Usage in NestJS

### Inject Prisma Service

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from '@/core/database';

@Injectable()
export class UserService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    return this.prisma.user.findMany({
      where: { deletedAt: null },
      include: { organization: true },
    });
  }

  async findOne(id: string) {
    return this.prisma.user.findUnique({
      where: { id },
      include: {
        organization: true,
        teamMemberships: {
          include: { team: true },
        },
      },
    });
  }
}
```

### Transactions

```typescript
async createBooking(data: CreateBookingDto) {
  return this.prisma.$transaction(async (tx) => {
    // Create invitee
    const invitee = await tx.invitee.create({
      data: {
        email: data.inviteeEmail,
        name: data.inviteeName,
        timezone: data.timezone,
      },
    });

    // Create booking
    const booking = await tx.booking.create({
      data: {
        eventTypeId: data.eventTypeId,
        hostId: data.hostId,
        inviteeId: invitee.id,
        startTime: data.startTime,
        endTime: data.endTime,
        timezone: data.timezone,
        location: data.location,
      },
    });

    return booking;
  });
}
```

### Soft Deletes

```typescript
// Soft delete (sets deletedAt)
async softDelete(id: string) {
  return this.prisma.user.update({
    where: { id },
    data: { deletedAt: new Date() },
  });
}

// Query excluding soft-deleted records
async findActive() {
  return this.prisma.user.findMany({
    where: { deletedAt: null },
  });
}
```

## Best Practices

1. **Always use transactions** for operations that modify multiple tables
2. **Use indexes** for frequently queried fields (already defined in schema)
3. **Implement soft deletes** using `deletedAt` (already implemented)
4. **Use parameterized queries** (Prisma does this automatically)
5. **Handle errors properly** with try-catch blocks
6. **Use connection pooling** (configured in PrismaService)
7. **Enable query logging** in development (configured in PrismaService)
8. **Close connections gracefully** (handled by PrismaService lifecycle hooks)

## PostgreSQL Extensions

The schema uses these PostgreSQL extensions:
- `uuid-ossp`: For UUID generation
- `pgcrypto`: For encryption functions (if needed)

These are automatically installed via the migration.

## Troubleshooting

### Connection Issues

1. Verify DATABASE_URL is correct
2. Check database is running and accessible
3. Verify SSL settings (required for Neon and most cloud providers)
4. Check firewall rules

### Migration Errors

1. Ensure database is accessible
2. Check for schema conflicts
3. Try `npx prisma migrate reset` (development only)
4. Verify PostgreSQL version compatibility (requires 12+)

### Type Generation Issues

1. Run `npx prisma generate` to regenerate types
2. Restart your IDE/TypeScript server
3. Check `node_modules/.prisma/client` directory exists

## Additional Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [PostgreSQL Best Practices](../../Claude/NodeJs.md#postgresql)
- [Neon Documentation](https://neon.tech/docs)
- [Schema Reference](./schema.prisma)
