import { DEFAULT_DEBOUNCE } from './DebounceConstants';

export const withDebounce = (action, debounce = DEFAULT_DEBOUNCE) => ({
  ...action,
  debounce,
});
