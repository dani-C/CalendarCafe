import { AxiosError } from 'axios';
import { ApiError } from '@/types';
import { Button } from '../Button';
import { ErrorMessageProps } from './ErrorMessage.types';
import styles from './ErrorMessage.module.css';

export const ErrorMessage = ({ error, message, onRetry }: ErrorMessageProps) => {
  const getErrorMessage = (): string => {
    if (message) return message;
    if (!error) return 'An unexpected error occurred';

    if (error instanceof AxiosError && error.response?.data) {
      const apiError = error.response.data as ApiError;
      return apiError.message || error.message;
    }

    return error.message || 'An unexpected error occurred';
  };

  return (
    <div className={styles.container} role="alert">
      <div className={styles.iconWrapper}>
        <svg
          className={styles.icon}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
          />
        </svg>
      </div>
      <div className={styles.content}>
        <p className={styles.message}>{getErrorMessage()}</p>
        {onRetry && (
          <Button variant="ghost" size="sm" onClick={onRetry}>
            Try again
          </Button>
        )}
      </div>
    </div>
  );
};
