import { Controller, Get } from '@nestjs/common';
import { HeartbeatService } from './heartbeat.service';

@Controller('heartbeat')
export class HeartbeatController {
  constructor(private readonly heartbeatService: HeartbeatService) {}

  @Get()
  getHeartbeat(): string {
    return this.heartbeatService.getHeartbeat();
  }
}
