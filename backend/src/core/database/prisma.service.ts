import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { ConfigService } from '@nestjs/config';

/**
 * Prisma Service
 *
 * Manages the Prisma Client lifecycle and provides database access
 * Following best practices:
 * - Connection pooling
 * - Graceful shutdown
 * - Query logging in development
 * - Error handling
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);

  constructor(private readonly configService: ConfigService) {
    super({
      datasources: {
        db: {
          url: configService.get<string>('DATABASE_URL'),
        },
      },
      log:
        configService.get<string>('NODE_ENV') === 'development'
          ? [
              { emit: 'event', level: 'query' },
              { emit: 'event', level: 'error' },
              { emit: 'event', level: 'warn' },
            ]
          : [{ emit: 'event', level: 'error' }],
    });
  }

  /**
   * Initialize database connection on module init
   */
  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('Database connected successfully');

      // Log queries in development
      if (this.configService.get<string>('NODE_ENV') === 'development') {
        this.$on('query' as never, (e: any) => {
          this.logger.debug(`Query: ${e.query}`);
          this.logger.debug(`Params: ${e.params}`);
          this.logger.debug(`Duration: ${e.duration}ms`);
        });
      }

      // Log errors
      this.$on('error' as never, (e: any) => {
        this.logger.error('Database error:', e);
      });

      // Log warnings
      this.$on('warn' as never, (e: any) => {
        this.logger.warn('Database warning:', e);
      });
    } catch (error) {
      this.logger.error('Failed to connect to database:', error);
      throw error;
    }
  }

  /**
   * Gracefully disconnect on module destroy
   */
  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('Database disconnected successfully');
    } catch (error) {
      this.logger.error('Error disconnecting from database:', error);
      throw error;
    }
  }

  /**
   * Health check - verifies database connectivity
   */
  async healthCheck(): Promise<boolean> {
    try {
      await this.$queryRaw`SELECT 1`;
      return true;
    } catch (error) {
      this.logger.error('Database health check failed:', error);
      return false;
    }
  }

  /**
   * Clean database - useful for testing
   * WARNING: Only use in test/development environments
   */
  async cleanDatabase(): Promise<void> {
    if (this.configService.get<string>('NODE_ENV') === 'production') {
      throw new Error('Cannot clean database in production');
    }

    const models = Object.keys(this).filter(
      (key) => !key.startsWith('_') && !key.startsWith('$'),
    );

    return this.$transaction(
      models.map((model) => (this as any)[model].deleteMany()),
    );
  }
}
