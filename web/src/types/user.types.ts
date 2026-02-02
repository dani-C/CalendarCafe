/**
 * User Types
 * Types for user-related data structures
 */

import { BaseEntity } from './common.types';

export type UserStatus = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
export type UserRole = 'OWNER' | 'ADMIN' | 'MEMBER' | 'VIEWER';

export interface User extends BaseEntity {
  email: string;
  name: string;
  avatar?: string;
  timezone: string;
  locale: string;
  status: UserStatus;
  emailVerified: boolean;
  lastLoginAt?: string;
  organizationId: string;
}

export interface CreateUserDTO {
  email: string;
  name: string;
  password: string;
  timezone?: string;
  locale?: string;
}

export interface UpdateUserDTO {
  name?: string;
  avatar?: string;
  timezone?: string;
  locale?: string;
}

export interface LoginDTO {
  email: string;
  password: string;
}

export interface RegisterDTO extends CreateUserDTO {
  confirmPassword: string;
}

export interface AuthResponse {
  user: User;
  accessToken: string;
  refreshToken: string;
}
