import debounce from 'lodash/debounce';
import { snakeCase, camelCase } from 'lodash';
import URI from 'urijs';
import { translate as __ } from './I18n';

/**
 * Does it run in phantomjs test environment
 * @return {boolean}
 */
export const runningInPhantomJS = () => window._phantom !== undefined;

/**
 * Add a debounce timeout for your methods.
 * @param {Object} context - the context where your method is running.
 * @param {Number} time - the amount of debounce time in miliseconds.
 * @param {Array} methods - Array that contains the methods to run on.
 */
export const debounceMethods = (context, time, methods) => {
  methods.forEach(method => {
    const methodName = method.name || method;
    const methodTime = method.time || time;
    // eslint-disable-next-line no-param-reassign
    context[methodName] = debounce(context[methodName], methodTime);
  });
};

/**
 * Bind your methods to run in a specific context.
 * @param {Object} context - the context where your method should run.
 * @param {Array} methods - Array that contains the methods to run on.
 */
export const bindMethods = (context, methods) => {
  methods.forEach(method => {
    // eslint-disable-next-line no-param-reassign
    context[method] = context[method].bind(context);
  });
};

/**
 * An empty function which is usually used as a default function.
 */
export const noop = Function.prototype;

/**
 * Opens the link in a new window.
 * @param {String} url - the path to open in a new window.
 */
export const newWindowOnClick = url => event => {
  event.preventDefault();
  const newWindow = window.open(url, '_blank');
  newWindow.opener = null;
};

/**
 * Clear the spaces in both sides of a string and erase multiple spaces.
 * @param {String} string - the string which should be trimmed.
 */
export const clearSpaces = string => string.trim().replace(/\s\s+/, ' ');

export const getDisplayName = Component =>
  Component.displayName || Component.name || 'Component';
/**
 * Use I18n to translate an object of strings
 * @param {Object.<string, string>} obj - the object to translate
 * @returns {Object.<string, string>} a translated object
 */
export const translateObject = obj =>
  Object.assign({}, ...Object.entries(obj).map(([k, v]) => ({ [k]: __(v) })));

/**
 * Use I18n to translate an array of strings
 * @param {Array.<string>} arr - the array to translate
 * @returns {Array.<string>} a translated array
 */
export const translateArray = arr => arr.map(str => __(str));

/**
 * Return the query in URL as Objects where keys are
 * the parameters and the values are the parameters' values.
 * @param {String} url - the URL
 */
export const getURIQuery = url => new URI(url).query(true);

/**
 * Transform object keys to snake case
 */
export const propsToSnakeCase = ob =>
  propsToCase(snakeCase, 'propsToSnakeCase only takes objects', ob);

/**
 * Transform object keys to camel case
 */
export const propsToCamelCase = ob =>
  propsToCase(camelCase, 'propsToCamelCase only takes objects', ob);

const propsToCase = (casingFn, errorMsg, ob) => {
  if (typeof ob !== 'object') throw Error(errorMsg);

  return Object.keys(ob).reduce((memo, key) => {
    memo[casingFn(key)] = ob[key];
    return memo;
  }, {});
};

export default {
  bindMethods,
  noop,
  debounceMethods,
  clearSpaces,
  newWindowOnClick,
  getDisplayName,
  translateObject,
  translateArray,
  propsToCamelCase,
  propsToSnakeCase,
};
