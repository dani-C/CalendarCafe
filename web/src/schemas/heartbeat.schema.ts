import { z } from 'zod';

export const HeartbeatSchema = z.string();

export type Heartbeat = z.infer<typeof HeartbeatSchema>;
