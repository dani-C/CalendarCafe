import { useState, useEffect } from 'react';

/**
 * useMediaQuery Hook
 *
 * Tracks whether a media query matches the current viewport.
 * Updates automatically when the viewport size changes.
 *
 * @param query - The media query string
 * @returns boolean indicating whether the query matches
 *
 * @example
 * const isMobile = useMediaQuery('(max-width: 767px)');
 * return isMobile ? <MobileNav /> : <DesktopNav />;
 */
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

    // Set initial value
    setMatches(mediaQuery.matches);

    // Listen for changes
    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, [query]);

  return matches;
}

/**
 * Predefined breakpoint hooks
 * Based on common device sizes
 */

export const useIsMobile = () => useMediaQuery('(max-width: 767px)');
export const useIsTablet = () =>
  useMediaQuery('(min-width: 768px) and (max-width: 1023px)');
export const useIsDesktop = () => useMediaQuery('(min-width: 1024px)');

// Additional utility hooks
export const useIsSmallScreen = () => useMediaQuery('(max-width: 639px)');
export const useIsMediumScreen = () =>
  useMediaQuery('(min-width: 640px) and (max-width: 1023px)');
export const useIsLargeScreen = () => useMediaQuery('(min-width: 1024px)');
export const useIsXLargeScreen = () => useMediaQuery('(min-width: 1280px)');
