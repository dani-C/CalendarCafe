import { Test, TestingModule } from '@nestjs/testing';
import { HeartbeatController } from './heartbeat.controller';
import { HeartbeatService } from './heartbeat.service';

describe('HeartbeatController', () => {
  let controller: HeartbeatController;
  let service: HeartbeatService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HeartbeatController],
      providers: [HeartbeatService],
    }).compile();

    controller = module.get<HeartbeatController>(HeartbeatController);
    service = module.get<HeartbeatService>(HeartbeatService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return "Hello"', () => {
    expect(controller.getHeartbeat()).toBe('Hello');
  });
});
