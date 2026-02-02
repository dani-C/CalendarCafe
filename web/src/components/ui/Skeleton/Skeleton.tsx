import { clsx } from 'clsx';
import { SkeletonProps } from './Skeleton.types';
import styles from './Skeleton.module.css';

export const Skeleton = ({
  width,
  height,
  variant = 'rectangular',
  animation = 'pulse',
  className,
  style,
  ...props
}: SkeletonProps) => {
  return (
    <div
      className={clsx(
        styles.skeleton,
        styles[variant],
        animation !== 'none' && styles[animation],
        className
      )}
      style={{
        width,
        height,
        ...style,
      }}
      {...props}
    />
  );
};
