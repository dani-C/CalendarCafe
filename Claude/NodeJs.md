# Best Practices for NestJS + TypeScript API Projects

## Project Structure

- Organize code by feature modules, not by file type
- Keep each module self-contained with its own controllers, services, and schemas
- Use a shared/common module for reusable utilities, decorators, and guards
- Separate configuration from business logic using NestJS ConfigModule

## TypeScript Configuration

- Enable strict mode in tsconfig.json
- Use path aliases for cleaner imports (e.g., `@modules/*`, `@common/*`)
- Define explicit return types for all functions and methods
- Create dedicated DTOs (Data Transfer Objects) for all request/response payloads
- Use enums for fixed value sets instead of magic strings

## MongoDB & Mongoose

- Define schemas using `@nestjs/mongoose` decorators
- Create indexes for frequently queried fields
- Use lean queries when you don't need Mongoose document methods
- Implement soft deletes with `deletedAt` timestamps instead of hard deletes
- Use transactions for operations that modify multiple documents
- Define virtual properties for computed fields
- Avoid storing large arrays in documents; use references instead

## PostgreSQL

### Schema Design

- Use proper data types (e.g., `UUID` for IDs, `TIMESTAMPTZ` for timestamps, `JSONB` for JSON data)
- Define primary keys, foreign keys, and constraints at the database level
- Use NOT NULL constraints where appropriate
- Implement CHECK constraints for data validation
- Normalize data to reduce redundancy, but denormalize strategically for performance
- Use database-level defaults (e.g., `DEFAULT NOW()` for timestamps)
- Create separate schemas for different application domains when needed

### Indexing & Performance

- Create indexes on foreign keys and frequently queried columns
- Use composite indexes for multi-column queries
- Add partial indexes for queries with common WHERE conditions
- Use covering indexes to avoid table lookups
- Monitor query performance with `EXPLAIN ANALYZE`
- Create indexes CONCURRENTLY in production to avoid locking
- Avoid over-indexing; each index has write overhead
- Use `pg_stat_statements` extension to identify slow queries

### Query Best Practices

- Use parameterized queries to prevent SQL injection (never concatenate user input)
- Prefer prepared statements for frequently executed queries
- Use connection pooling (e.g., with `pg-pool` or `@neondatabase/serverless`)
- Batch inserts/updates when possible using array operations
- Use `RETURNING *` to get inserted/updated data in one query
- Leverage CTEs (Common Table Expressions) for complex queries
- Use window functions instead of subqueries when appropriate
- Avoid `SELECT *`; explicitly specify needed columns

### Transactions & Concurrency

- Use transactions for operations that modify multiple tables
- Set appropriate isolation levels based on your consistency needs
- Use row-level locking (`SELECT ... FOR UPDATE`) when needed
- Keep transactions short to minimize lock contention
- Handle deadlock errors with retry logic
- Use optimistic locking with version columns for concurrent updates
- Consider using advisory locks for application-level coordination

### TypeORM / Prisma Integration

#### TypeORM
- Define entities with proper column types and decorators
- Use repositories or custom repository classes for data access
- Enable synchronization only in development; use migrations in production
- Use query builders for complex dynamic queries
- Leverage eager/lazy loading appropriately
- Use transactions with QueryRunner for multi-step operations
- Avoid N+1 queries by using relations and joins properly

#### Prisma
- Use Prisma schema to define models with proper field types
- Generate migrations for schema changes (`prisma migrate dev`)
- Use Prisma Client's type-safe query API
- Leverage `select` and `include` to control data fetching
- Use nested writes for related records
- Enable query logging in development with `log: ['query']`
- Use connection pooling with PgBouncer for serverless environments

### Data Integrity & Constraints

- Use foreign key constraints with appropriate CASCADE actions
- Implement unique constraints where needed
- Add CHECK constraints for business rules at the database level
- Use ENUM types for fixed value sets (or check constraints)
- Implement soft deletes with `deleted_at` columns and partial indexes
- Use triggers sparingly; prefer application logic for complex operations
- Validate data at both application and database levels

### Security

- Use parameterized queries exclusively to prevent SQL injection
- Grant minimum necessary privileges to database users
- Use separate database users for different application components
- Enable SSL/TLS for database connections in production
- Rotate database credentials regularly
- Never log sensitive data from queries
- Use Row-Level Security (RLS) for multi-tenant applications
- Hash sensitive data before storing (use `pgcrypto` extension if needed)

### Migrations & Schema Management

- Use migration tools (TypeORM migrations, Prisma Migrate, or node-pg-migrate)
- Version control all migration files
- Test migrations on staging before production
- Write both `up` and `down` migrations
- Make migrations backwards-compatible when possible
- Use transactions in migrations to ensure atomicity
- Create indexes CONCURRENTLY in separate migrations to avoid downtime

### Connection Management

- Use connection pooling with appropriate pool size limits
- Configure connection timeouts appropriately
- Implement connection retry logic with exponential backoff
- Close connections gracefully on application shutdown
- Monitor active connections and pool utilization
- For serverless: use HTTP-based connections (e.g., Neon serverless driver) or PgBouncer
- Set `idle_in_transaction_session_timeout` to prevent hanging transactions

### Full-Text Search

- Use PostgreSQL's built-in full-text search with `tsvector` and `tsquery`
- Create GIN indexes on `tsvector` columns for performance
- Use trigram similarity with `pg_trgm` extension for fuzzy matching
- Consider separate search columns with triggers to maintain search indexes
- Normalize search queries for better match rates
- Use search rankings with `ts_rank` to order results

### JSON/JSONB Usage

- Prefer JSONB over JSON for better performance and indexing
- Create GIN indexes on JSONB columns for query performance
- Use JSONB operators (`->`, `->>`, `@>`, etc.) for efficient querying
- Validate JSON structure with CHECK constraints when needed
- Don't overuse JSONB; use proper columns for structured data
- Consider JSONB for truly dynamic/flexible fields

### Monitoring & Maintenance

- Enable and monitor slow query logs
- Set up regular VACUUM and ANALYZE operations (or rely on autovacuum)
- Monitor table bloat and dead tuples
- Track database size and growth patterns
- Monitor connection counts and pool utilization
- Set up alerts for long-running queries
- Use `pg_stat_activity` to monitor active queries
- Regularly review and optimize slow queries

### Validation & Transformation

- Use class-validator decorators on all DTOs
- Enable global ValidationPipe with `whitelist: true` and `transform: true`
- Create custom validators for complex business rules
- Use class-transformer to sanitize and transform incoming data

## Error Handling

- Create custom exception filters for consistent error responses
- Define business-specific exceptions extending HttpException
- Log errors with contextual information (request ID, user ID, endpoint)
- Never expose stack traces or internal details in production responses

## Authentication & Authorization

- Use Passport.js with NestJS guards for authentication
- Implement JWT with refresh token rotation
- Create role-based and permission-based guards
- Store sensitive data (passwords, tokens) hashed with bcrypt
- Use guards at controller or route level, not in services

## Security

- Enable helmet middleware for HTTP security headers
- Implement rate limiting with @nestjs/throttler
- Sanitize user inputs to prevent NoSQL injection
- Use CORS configuration appropriate for your deployment
- Never commit secrets; use environment variables
- Validate and sanitize all MongoDB query parameters

## Performance

- Implement pagination for all list endpoints
- Use caching with Redis for frequently accessed data
- Enable compression for responses
- Use database connection pooling
- Implement request timeout handling
- Add database query logging in development only

## Testing

- Write unit tests for services with mocked dependencies
- Write integration tests for controllers with supertest
- Use in-memory MongoDB (mongodb-memory-server) for tests
- Aim for high coverage on business logic, not boilerplate
- Create test factories for generating mock data

## Logging & Monitoring

- Use a structured logger (e.g., winston, pino) instead of console.log
- Include correlation IDs in all log entries
- Log incoming requests and outgoing responses
- Set up health check endpoints for monitoring
- Track response times and error rates

## API Design

- Follow RESTful conventions for endpoints and HTTP methods
- Version your API (e.g., `/api/v1/`)
- Use consistent response envelope format
- Document endpoints with Swagger/OpenAPI decorators
- Return appropriate HTTP status codes

## Code Quality

- Use ESLint with TypeScript rules
- Enable Prettier for consistent formatting
- Run linting and tests in CI pipeline before merging
- Keep services focused on single responsibilities
- Avoid circular dependencies between modules

## Environment Configuration

- Use ConfigModule with validation schema (Joi or class-validator)
- Define separate configs for development, staging, and production
- Never hardcode environment-specific values
- Validate all required environment variables at startup

## Deployment

- Use Docker with multi-stage builds for smaller images
- Implement graceful shutdown handling
- Set up database migrations strategy for schema changes
- Use connection retry logic for database connectivity
- Configure appropriate MongoDB read/write concerns for your use case