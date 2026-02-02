import { InputHTMLAttributes, ReactNode } from 'react';
import { Size } from '@/types';

export type InputSize = Size;

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helperText?: string;
  size?: InputSize;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
}
