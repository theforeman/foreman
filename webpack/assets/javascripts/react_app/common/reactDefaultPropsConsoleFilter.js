const defaultPropsDeprecationPattern =
  'Support for defaultProps will be removed from function components';

const reactDevConsoleNoisePatterns = [
  defaultPropsDeprecationPattern,
  'uses the legacy childContextTypes API',
  'uses the legacy contextTypes API',
  'not wrapped in act',
  'Attempted to synchronously unmount a root while React was already rendering',
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

// React dev logging may emit the warning and companion stack lines separately.
let defaultPropsFollowUpSuppressions = 0;

/**
 * @returns {'suppress'|null}
 */
export const handleReactDefaultPropsConsoleError = (message, ...args) => {
  if (defaultPropsFollowUpSuppressions > 0) {
    defaultPropsFollowUpSuppressions -= 1;
    return 'suppress';
  }

  if (!isReactDevConsoleNoise(message, args)) {
    return null;
  }

  defaultPropsFollowUpSuppressions = 3;
  return 'suppress';
};

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
