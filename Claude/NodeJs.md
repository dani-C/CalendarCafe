# Best Practices for NestJS + TypeScript + MongoDB API Projects

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

## Validation & Transformation

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