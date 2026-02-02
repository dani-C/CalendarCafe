import { clsx } from 'clsx';
import { CardProps } from './Card.types';
import styles from './Card.module.css';

export const Card = ({
  children,
  padding = 'md',
  shadow = 'sm',
  className,
  ...props
}: CardProps) => {
  return (
    <div
      className={clsx(
        styles.card,
        styles[`padding-${padding}`],
        styles[`shadow-${shadow}`],
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};
