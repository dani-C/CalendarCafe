import { useQuery } from '@tanstack/react-query';
import { heartbeatService } from '@/api/services/heartbeat.service';

export const heartbeatKeys = {
  all: ['heartbeat'] as const,
  status: () => [...heartbeatKeys.all, 'status'] as const,
};

export const useHeartbeat = () => {
  return useQuery({
    queryKey: heartbeatKeys.status(),
    queryFn: heartbeatService.getHeartbeat,
    staleTime: 30 * 1000, // 30 seconds
    refetchInterval: 5000, // Poll every 5 seconds
  });
};
