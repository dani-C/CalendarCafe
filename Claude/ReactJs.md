# React + TypeScript Best Practices Guide

> **Purpose:** This document serves as a reference for building scalable, maintainable React applications with TypeScript and a Node.js backend API. It can be used as instructions for AI agents or as a team style guide.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Package Dependencies](#package-dependencies)
3. [TypeScript Configuration](#typescript-configuration)
4. [API Client Setup](#api-client-setup)
5. [REST API Consumption Patterns](#rest-api-consumption-patterns)
6. [Component Patterns](#component-patterns)
7. [Custom Hooks](#custom-hooks)
8. [Error Handling](#error-handling)
9. [Responsive Design](#responsive-design)
10. [Environment Variables](#environment-variables)
11. [Code Style Guidelines](#code-style-guidelines)

---

## Project Structure

```
project-root/
├── public/
│   └── assets/
├── src/
│   ├── api/                      # API layer
│   │   ├── client.ts             # Axios/fetch instance with interceptors
│   │   ├── endpoints.ts          # API endpoint constants
│   │   └── services/             # Domain-specific API functions
│   │       ├── auth.service.ts
│   │       ├── users.service.ts
│   │       └── index.ts
│   │
│   ├── components/
│   │   ├── ui/                   # Reusable UI primitives
│   │   │   ├── Button/
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Button.types.ts
│   │   │   │   ├── Button.module.css
│   │   │   │   └── index.ts
│   │   │   ├── Input/
│   │   │   ├── Modal/
│   │   │   └── index.ts
│   │   │
│   │   ├── layout/               # Layout components
│   │   │   ├── Header/
│   │   │   ├── Sidebar/
│   │   │   ├── Footer/
│   │   │   └── PageLayout/
│   │   │
│   │   └── features/             # Feature-specific components
│   │       ├── auth/
│   │       │   ├── LoginForm/
│   │       │   └── RegisterForm/
│   │       └── users/
│   │           ├── UserCard/
│   │           └── UserList/
│   │
│   ├── hooks/                    # Global custom hooks
│   │   ├── useAuth.ts
│   │   ├── useMediaQuery.ts
│   │   ├── useDebounce.ts
│   │   └── index.ts
│   │
│   ├── pages/                    # Route-level components
│   │   ├── Home/
│   │   │   ├── Home.tsx
│   │   │   └── index.ts
│   │   ├── Dashboard/
│   │   └── NotFound/
│   │
│   ├── types/                    # Global TypeScript types
│   │   ├── api.types.ts
│   │   ├── user.types.ts
│   │   ├── common.types.ts
│   │   └── index.ts
│   │
│   ├── schemas/                  # Zod validation schemas
│   │   ├── user.schema.ts
│   │   ├── auth.schema.ts
│   │   └── index.ts
│   │
│   ├── context/                  # React context providers
│   │   ├── AuthContext.tsx
│   │   ├── ThemeContext.tsx
│   │   └── index.ts
│   │
│   ├── utils/                    # Pure utility functions
│   │   ├── formatters.ts
│   │   ├── validators.ts
│   │   ├── storage.ts
│   │   └── index.ts
│   │
│   ├── constants/                # Application constants
│   │   ├── routes.ts
│   │   ├── config.ts
│   │   └── index.ts
│   │
│   ├── styles/                   # Global styles
│   │   ├── globals.css
│   │   ├── variables.css
│   │   └── breakpoints.css
│   │
│   ├── App.tsx
│   ├── main.tsx
│   └── vite-env.d.ts
│
├── .env.example
├── .eslintrc.cjs
├── .prettierrc
├── tsconfig.json
├── vite.config.ts
└── package.json
```

### Structure Principles

1. **Colocation:** Keep related files together. A component folder contains its `.tsx`, `.types.ts`, `.module.css`, and `index.ts`.
2. **Barrel exports:** Use `index.ts` files for clean imports: `import { Button, Input } from '@/components/ui'`
3. **Feature folders:** When a feature grows complex, give it its own `components/`, `hooks/`, and `types/` subfolders.
4. **Flat when possible:** Avoid deep nesting. If a folder only has one file, consider flattening.

---

## Package Dependencies

### Essential Dependencies

```json
{
  "dependencies": {
    "react": "^18.x",
    "react-dom": "^18.x",
    "react-router-dom": "^6.x",
    "@tanstack/react-query": "^5.x",
    "axios": "^1.x",
    "zod": "^3.x"
  },
  "devDependencies": {
    "typescript": "^5.x",
    "@types/react": "^18.x",
    "@types/react-dom": "^18.x",
    "vite": "^5.x",
    "@vitejs/plugin-react": "^4.x",
    "eslint": "^8.x",
    "@typescript-eslint/eslint-plugin": "^7.x",
    "@typescript-eslint/parser": "^7.x",
    "prettier": "^3.x"
  }
}
```

### Recommended Optional Dependencies

```json
{
  "dependencies": {
    "clsx": "^2.x",
    "date-fns": "^3.x",
    "react-hook-form": "^7.x",
    "@hookform/resolvers": "^3.x"
  }
}
```

### Styling Options (choose one)

**Option A: Tailwind CSS**
```json
{
  "devDependencies": {
    "tailwindcss": "^3.x",
    "postcss": "^8.x",
    "autoprefixer": "^10.x"
  }
}
```

**Option B: CSS Modules** (built into Vite, no extra dependencies)

**Option C: Styled Components**
```json
{
  "dependencies": {
    "styled-components": "^6.x"
  },
  "devDependencies": {
    "@types/styled-components": "^5.x"
  }
}
```

### What to Avoid Initially

- **Redux/Zustand:** React Query handles server state; `useContext` + `useReducer` handles most client state. Add these only when you feel genuine pain.
- **Lodash:** Modern JavaScript covers most use cases. Import individual functions if needed.
- **Moment.js:** Use `date-fns` instead (smaller, tree-shakeable).

---

## TypeScript Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,

    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### Vite Path Alias Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

---

## API Client Setup

### Base API Client

```typescript
// src/api/client.ts
import axios, { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api';

export const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - attach auth token
apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('accessToken');
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error: AxiosError) => Promise.reject(error)
);

// Response interceptor - handle errors globally
apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config;

    // Handle 401 - Token expired
    if (error.response?.status === 401) {
      // Option 1: Redirect to login
      localStorage.removeItem('accessToken');
      window.location.href = '/login';

      // Option 2: Implement refresh token logic here
    }

    // Handle 403 - Forbidden
    if (error.response?.status === 403) {
      console.error('Access forbidden');
    }

    // Handle 500 - Server error
    if (error.response?.status && error.response.status >= 500) {
      console.error('Server error occurred');
    }

    return Promise.reject(error);
  }
);
```

### API Endpoints Constants

```typescript
// src/api/endpoints.ts
export const ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    LOGOUT: '/auth/logout',
    REFRESH: '/auth/refresh',
    ME: '/auth/me',
  },
  USERS: {
    BASE: '/users',
    BY_ID: (id: string) => `/users/${id}`,
    PROFILE: (id: string) => `/users/${id}/profile`,
  },
  // Add more endpoint groups as needed
} as const;
```

---

## REST API Consumption Patterns

### 1. Define Types and Schemas

```typescript
// src/types/user.types.ts
export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  role: 'admin' | 'user';
  createdAt: string;
  updatedAt: string;
}

export interface CreateUserDTO {
  email: string;
  name: string;
  password: string;
}

export interface UpdateUserDTO {
  name?: string;
  avatar?: string;
}
```

```typescript
// src/schemas/user.schema.ts
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
  avatar: z.string().url().optional(),
  role: z.enum(['admin', 'user']),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export const UsersListSchema = z.array(UserSchema);

// Infer types from schemas for consistency
export type UserFromSchema = z.infer<typeof UserSchema>;
```

### 2. Create Service Functions

```typescript
// src/api/services/users.service.ts
import { apiClient } from '../client';
import { ENDPOINTS } from '../endpoints';
import { User, CreateUserDTO, UpdateUserDTO } from '@/types/user.types';
import { UserSchema, UsersListSchema } from '@/schemas/user.schema';

export const usersService = {
  getAll: async (): Promise<User[]> => {
    const { data } = await apiClient.get(ENDPOINTS.USERS.BASE);
    return UsersListSchema.parse(data);
  },

  getById: async (id: string): Promise<User> => {
    const { data } = await apiClient.get(ENDPOINTS.USERS.BY_ID(id));
    return UserSchema.parse(data);
  },

  create: async (payload: CreateUserDTO): Promise<User> => {
    const { data } = await apiClient.post(ENDPOINTS.USERS.BASE, payload);
    return UserSchema.parse(data);
  },

  update: async (id: string, payload: UpdateUserDTO): Promise<User> => {
    const { data } = await apiClient.patch(ENDPOINTS.USERS.BY_ID(id), payload);
    return UserSchema.parse(data);
  },

  delete: async (id: string): Promise<void> => {
    await apiClient.delete(ENDPOINTS.USERS.BY_ID(id));
  },
};
```

### 3. Create React Query Hooks

```typescript
// src/hooks/api/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { usersService } from '@/api/services/users.service';
import { CreateUserDTO, UpdateUserDTO } from '@/types/user.types';

// Query key factory for consistency
export const userKeys = {
  all: ['users'] as const,
  lists: () => [...userKeys.all, 'list'] as const,
  list: (filters: Record<string, unknown>) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, 'detail'] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// Fetch all users
export const useUsers = () => {
  return useQuery({
    queryKey: userKeys.lists(),
    queryFn: usersService.getAll,
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

// Fetch single user
export const useUser = (id: string) => {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => usersService.getById(id),
    enabled: Boolean(id),
  });
};

// Create user mutation
export const useCreateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (payload: CreateUserDTO) => usersService.create(payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
};

// Update user mutation
export const useUpdateUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: UpdateUserDTO }) =>
      usersService.update(id, payload),
    onSuccess: (data, variables) => {
      queryClient.invalidateQueries({ queryKey: userKeys.detail(variables.id) });
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
};

// Delete user mutation
export const useDeleteUser = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => usersService.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
};
```

### 4. Configure Query Client

```typescript
// src/main.tsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ReactQueryDevtools } from '@tanstack/react-query-devtools';
import App from './App';
import './styles/globals.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
      staleTime: 30 * 1000, // 30 seconds default
    },
    mutations: {
      retry: 0,
    },
  },
});

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  </React.StrictMode>
);
```

---

## Component Patterns

### Basic Component Structure

```typescript
// src/components/ui/Button/Button.types.ts
import { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'danger' | 'ghost';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
  children: ReactNode;
}
```

```typescript
// src/components/ui/Button/Button.tsx
import { forwardRef } from 'react';
import { clsx } from 'clsx';
import { ButtonProps } from './Button.types';
import styles from './Button.module.css';

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      isLoading = false,
      leftIcon,
      rightIcon,
      children,
      className,
      disabled,
      ...props
    },
    ref
  ) => {
    return (
      <button
        ref={ref}
        className={clsx(
          styles.button,
          styles[variant],
          styles[size],
          isLoading && styles.loading,
          className
        )}
        disabled={disabled || isLoading}
        {...props}
      >
        {isLoading ? (
          <span className={styles.spinner} />
        ) : (
          <>
            {leftIcon && <span className={styles.icon}>{leftIcon}</span>}
            {children}
            {rightIcon && <span className={styles.icon}>{rightIcon}</span>}
          </>
        )}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

```typescript
// src/components/ui/Button/index.ts
export { Button } from './Button';
export type { ButtonProps, ButtonVariant, ButtonSize } from './Button.types';
```

### Component with API Data

```typescript
// src/components/features/users/UserList/UserList.tsx
import { useUsers } from '@/hooks/api/useUsers';
import { UserCard } from '../UserCard';
import { Skeleton } from '@/components/ui/Skeleton';
import { ErrorMessage } from '@/components/ui/ErrorMessage';
import styles from './UserList.module.css';

export const UserList = () => {
  const { data: users, isLoading, error, refetch } = useUsers();

  if (isLoading) {
    return (
      <div className={styles.grid}>
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} height={200} />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <ErrorMessage
        message="Failed to load users"
        onRetry={refetch}
      />
    );
  }

  if (!users?.length) {
    return <p className={styles.empty}>No users found</p>;
  }

  return (
    <div className={styles.grid}>
      {users.map((user) => (
        <UserCard key={user.id} user={user} />
      ))}
    </div>
  );
};
```

---

## Custom Hooks

### useDebounce

```typescript
// src/hooks/useDebounce.ts
import { useState, useEffect } from 'react';

export function useDebounce<T>(value: T, delay: number = 500): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

### useMediaQuery

```typescript
// src/hooks/useMediaQuery.ts
import { useState, useEffect } from 'react';

export function useMediaQuery(query: string): boolean {
  const [matches, setMatches] = useState(() => {
    if (typeof window !== 'undefined') {
      return window.matchMedia(query).matches;
    }
    return false;
  });

  useEffect(() => {
    const mediaQuery = window.matchMedia(query);
    const handler = (event: MediaQueryListEvent) => setMatches(event.matches);

    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
}

// Predefined breakpoint hooks
export const useIsMobile = () => useMediaQuery('(max-width: 767px)');
export const useIsTablet = () => useMediaQuery('(min-width: 768px) and (max-width: 1023px)');
export const useIsDesktop = () => useMediaQuery('(min-width: 1024px)');
```

### useLocalStorage

```typescript
// src/hooks/useLocalStorage.ts
import { useState, useEffect } from 'react';

export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T | ((prev: T) => T)) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  useEffect(() => {
    try {
      localStorage.setItem(key, JSON.stringify(storedValue));
    } catch (error) {
      console.error(`Error saving to localStorage key "${key}":`, error);
    }
  }, [key, storedValue]);

  return [storedValue, setStoredValue];
}
```

---

## Error Handling

### API Error Types

```typescript
// src/types/api.types.ts
export interface ApiError {
  message: string;
  code: string;
  statusCode: number;
  details?: Record<string, string[]>;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    pageSize: number;
    totalPages: number;
  };
}
```

### Error Boundary Component

```typescript
// src/components/ErrorBoundary.tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Send to error tracking service (Sentry, etc.)
  }

  render() {
    if (this.state.hasError) {
      return (
        this.props.fallback || (
          <div role="alert">
            <h2>Something went wrong</h2>
            <button onClick={() => this.setState({ hasError: false })}>
              Try again
            </button>
          </div>
        )
      );
    }

    return this.props.children;
  }
}
```

### Reusable Error Message Component

```typescript
// src/components/ui/ErrorMessage/ErrorMessage.tsx
import { AxiosError } from 'axios';
import { ApiError } from '@/types/api.types';
import styles from './ErrorMessage.module.css';

interface ErrorMessageProps {
  error?: Error | AxiosError<ApiError> | null;
  message?: string;
  onRetry?: () => void;
}

export const ErrorMessage = ({ error, message, onRetry }: ErrorMessageProps) => {
  const getErrorMessage = (): string => {
    if (message) return message;
    if (!error) return 'An unexpected error occurred';

    if (error instanceof AxiosError && error.response?.data) {
      return error.response.data.message || error.message;
    }

    return error.message || 'An unexpected error occurred';
  };

  return (
    <div className={styles.container} role="alert">
      <p className={styles.message}>{getErrorMessage()}</p>
      {onRetry && (
        <button className={styles.retryButton} onClick={onRetry}>
          Try again
        </button>
      )}
    </div>
  );
};
```

---

## Responsive Design

### CSS Breakpoints

```css
/* src/styles/breakpoints.css */
:root {
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
  --breakpoint-2xl: 1536px;
}

/* Mobile-first media queries */
@custom-media --sm (min-width: 640px);
@custom-media --md (min-width: 768px);
@custom-media --lg (min-width: 1024px);
@custom-media --xl (min-width: 1280px);
@custom-media --2xl (min-width: 1536px);
```

### CSS Module Example

```css
/* src/components/features/users/UserList/UserList.module.css */
.grid {
  display: grid;
  gap: 1rem;
  grid-template-columns: 1fr;
}

@media (min-width: 640px) {
  .grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 1.5rem;
  }
}

.empty {
  text-align: center;
  padding: 2rem;
  color: var(--color-text-muted);
}
```

### Responsive Component Pattern

```typescript
// src/components/layout/PageLayout/PageLayout.tsx
import { ReactNode } from 'react';
import { useIsMobile } from '@/hooks/useMediaQuery';
import { Sidebar } from '../Sidebar';
import { MobileNav } from '../MobileNav';
import styles from './PageLayout.module.css';

interface PageLayoutProps {
  children: ReactNode;
}

export const PageLayout = ({ children }: PageLayoutProps) => {
  const isMobile = useIsMobile();

  return (
    <div className={styles.layout}>
      {isMobile ? <MobileNav /> : <Sidebar />}
      <main className={styles.main}>{children}</main>
    </div>
  );
};
```

---

## Environment Variables

### .env.example

```env
# API Configuration
VITE_API_URL=http://localhost:3000/api
VITE_API_TIMEOUT=10000

# Feature Flags
VITE_ENABLE_ANALYTICS=false
VITE_ENABLE_DEBUG_MODE=false

# Third-party Services
VITE_SENTRY_DSN=
```

### Type-safe Environment Variables

```typescript
// src/utils/env.ts
import { z } from 'zod';

const envSchema = z.object({
  VITE_API_URL: z.string().url(),
  VITE_API_TIMEOUT: z.string().transform(Number).default('10000'),
  VITE_ENABLE_ANALYTICS: z.string().transform((v) => v === 'true').default('false'),
  VITE_ENABLE_DEBUG_MODE: z.string().transform((v) => v === 'true').default('false'),
});

const parseEnv = () => {
  const parsed = envSchema.safeParse(import.meta.env);

  if (!parsed.success) {
    console.error('❌ Invalid environment variables:', parsed.error.flatten().fieldErrors);
    throw new Error('Invalid environment variables');
  }

  return parsed.data;
};

export const env = parseEnv();
```

---

## Code Style Guidelines

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserCard.tsx` |
| Hooks | camelCase with `use` prefix | `useAuth.ts` |
| Utils | camelCase | `formatDate.ts` |
| Types/Interfaces | PascalCase | `User`, `ApiResponse` |
| Constants | SCREAMING_SNAKE_CASE | `API_BASE_URL` |
| CSS Modules | camelCase | `styles.cardContainer` |
| Files | kebab-case or PascalCase | `user-card.module.css` or `UserCard.tsx` |

### ESLint Configuration

```javascript
// .eslintrc.cjs
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
    'plugin:react/recommended',
    'plugin:react/jsx-runtime',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-refresh'],
  rules: {
    'react-refresh/only-export-components': ['warn', { allowConstantExport: true }],
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    'react/prop-types': 'off',
  },
  settings: {
    react: { version: 'detect' },
  },
};
```

### Prettier Configuration

```json
// .prettierrc
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

---

## Quick Reference Commands

```bash
# Create new Vite React TypeScript project
npm create vite@latest my-app -- --template react-ts

# Install core dependencies
npm install axios @tanstack/react-query react-router-dom zod

# Install dev dependencies
npm install -D @tanstack/react-query-devtools

# Install Tailwind (optional)
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# Run development server
npm run dev

# Build for production
npm run build

# Type check
npx tsc --noEmit

# Lint
npm run lint
```

---

## Checklist for New Features

When implementing a new feature, follow this checklist:

- [ ] Define TypeScript types in `src/types/`
- [ ] Create Zod schema for API response validation in `src/schemas/`
- [ ] Add API service functions in `src/api/services/`
- [ ] Create React Query hooks in `src/hooks/api/`
- [ ] Build UI components with proper loading/error states
- [ ] Add responsive styles
- [ ] Write unit tests for critical logic
- [ ] Update route configuration if needed

---

*Last updated: 2025*