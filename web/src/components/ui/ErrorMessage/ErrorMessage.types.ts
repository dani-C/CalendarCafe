import { AxiosError } from 'axios';
import { ApiError } from '@/types';

export interface ErrorMessageProps {
  error?: Error | AxiosError<ApiError> | null;
  message?: string;
  onRetry?: () => void;
}
