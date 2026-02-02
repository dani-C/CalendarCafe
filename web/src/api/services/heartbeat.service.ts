import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';
import { HeartbeatSchema } from '@/schemas/heartbeat.schema';

export const heartbeatService = {
  getHeartbeat: async (): Promise<string> => {
    const { data } = await apiClient.get<string>(ENDPOINTS.HEARTBEAT);
    return HeartbeatSchema.parse(data);
  },
};
