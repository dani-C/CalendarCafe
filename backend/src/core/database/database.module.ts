import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaService } from './prisma.service';

/**
 * Database Module
 *
 * Global module that provides database access via Prisma
 * Best practices:
 * - Global module to avoid re-importing in every module
 * - Exports PrismaService for use throughout the app
 * - Handles connection lifecycle automatically
 */
@Global()
@Module({
  imports: [ConfigModule],
  providers: [PrismaService],
  exports: [PrismaService],
})
export class DatabaseModule {}
