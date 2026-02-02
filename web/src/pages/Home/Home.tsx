import { useHeartbeat } from '@/hooks/useHeartbeat';
import styles from './Home.module.css';

export const Home = () => {
  const { data: heartbeat, isLoading, error } = useHeartbeat();

  return (
    <div className={styles.container}>
      <div className={styles.content}>
        <h1>Calendar Cafe</h1>
        <p className={styles.subtitle}>React + TypeScript Frontend</p>

        <div className={styles.statusSection}>
          <h2>Backend Status</h2>
          <div className={styles.statusCard}>
            {isLoading && <p>Loading...</p>}
            {error && (
              <p className={styles.error}>
                Error: {error instanceof Error ? error.message : 'Unknown error'}
              </p>
            )}
            {heartbeat && (
              <div>
                <p className={styles.statusLabel}>Heartbeat Response:</p>
                <p className={styles.statusValue}>{heartbeat}</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
