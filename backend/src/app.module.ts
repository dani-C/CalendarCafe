import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { DatabaseModule } from '@core/database/database.module';
import { HeartbeatModule } from '@modules/heartbeat/heartbeat.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    DatabaseModule,
    HeartbeatModule,
  ],
})
export class AppModule {}
