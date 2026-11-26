const defaultPropsDeprecationPattern =
  'Support for defaultProps will be removed from function components';

const reactDevConsoleNoisePatterns = [
  defaultPropsDeprecationPattern,
  'uses the legacy childContextTypes API',
  'uses the legacy contextTypes API',
  'not wrapped in act',
];

const isReactDevConsoleNoise = (message, ...args) =>
  [message, ...args].some(part => {
    const text =
      // eslint-disable-next-line no-nested-ternary
      typeof part === 'string'
        ? part
        : part instanceof Error
        ? part.message
        : '';
    return reactDevConsoleNoisePatterns.some(pattern => text.includes(pattern));
  });

/**
 * Suppress only this call. React attaches a component stack as another
 * argument on the same console.error, not as later calls.
 * @returns {'suppress'|null}
 */
export const handleReactDefaultPropsConsoleError = (message, ...args) =>
  isReactDevConsoleNoise(message, ...args) ? 'suppress' : null;

export const installReactDefaultPropsConsoleFilter = () => {
  if (
    typeof console === 'undefined' ||
    console.error.__foremanDefaultPropsFilter
  ) {
    return;
  }

  const originalError = console.error.bind(console);

  const patchedError = (message, ...args) => {
    if (handleReactDefaultPropsConsoleError(message, ...args) === 'suppress') {
      return;
    }
    originalError(message, ...args);
  };

  patchedError.__foremanDefaultPropsFilter = true;
  // eslint-disable-next-line no-console
  console.error = patchedError;
};
