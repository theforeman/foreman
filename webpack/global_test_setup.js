// eslint-disable-next-line import/no-unresolved, import/extensions
import 'core-js/shim';
// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime';

// https://github.com/facebook/jest/issues/6121
// eslint-disable-next-line no-console
const { error } = console;
// eslint-disable-next-line no-console
console.error = (message, ...args) => {
  error.apply(console, args); // keep default behaviour
  const err = message instanceof Error ? message : new Error(message);
  throw err;
};
