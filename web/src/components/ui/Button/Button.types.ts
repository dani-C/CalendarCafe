import { ButtonHTMLAttributes, ReactNode } from 'react';
import { Variant, Size } from '@/types';

export type ButtonVariant = Variant;
export type ButtonSize = Size;

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  children: ReactNode;
}
