import { snakeCase, camelCase, debounce } from 'lodash';
import URI from 'urijs';
import { deprecate } from './DeprecationService';
import { translate as __ } from './I18n';

/**
 * Our API returns non-ISO8601 dates
 * This method converts those strings into ISO8601 format
 * @param {String} date - non-ISO date to convert
 */
export const isoCompatibleDate = date => {
  if (
    typeof date === 'string' &&
    date.match(/\d{4}-\d\d-\d\d\s\d\d:\d\d:\d\d\s[+-]?\d{4}/)
  ) {
    // we've matched a date in the format: 2019-03-14 15:39:27 -0400
    return date.replace(/\s/, 'T').replace(/\s/, '');
  }

  return date;
};

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
 * Removes slashes from the beggining and end of the path
 * @param {String} path - the path that should be removed of slashes
 */
export const removeLastSlashFromPath = path => {
  if (!path || path.length < 2) return path;
  const lastCharIndex = path.length - 1;
  return path[lastCharIndex] === '/' ? path.slice(0, -1) : path;
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

/**
 * Transform object keys to camel case, works for nested objects
 */
export const deepPropsToCamelCase = obj =>
  deepPropsToCase(camelCase, 'propsToCamelCase only takes objects')(obj);

/**
 * Transform object keys to snake case, works for nested objects
 */
export const deepPropsToSnakeCase = obj =>
  deepPropsToCase(snakeCase, 'propsToSnakeCase only takes objects')(obj);

const deepPropsToCase = (casingFn, errorMsg) => obj => {
  if (typeof obj !== 'object' || obj === null) {
    return obj;
  }
  if (Array.isArray(obj)) {
    return obj.map(deepPropsToCase(casingFn, errorMsg));
  }
  const transformed = propsToCase(casingFn, errorMsg, obj);
  return Object.keys(transformed).reduce((memo, key) => {
    memo[key] = deepPropsToCase(casingFn, errorMsg)(transformed[key]);
    return memo;
  }, {});
};

/**
 * Check if a string is a positive integer
 * @param {String} value - the string
 */
export const stringIsPositiveNumber = value => {
  const reg = new RegExp('^[0-9]+$');
  return reg.test(value);
};

/**
 * Get manual url based on version
 * @param {String} section - section id for foreman documetation
 */
export const getManualURL = section => `/links/manual/${section}`;
export const getWikiURL = section => `/links/wiki/${section}`;

/**
 * Transform the Date object to date string accepted in the server
 * @param {Date}
 * @returns {string}
 */
export const formatDate = date => formatDateTime(date).split(' ')[0];

/**
 * Transform the Date object to datetime string accepted in the server
 * @param {Date}
 * @returns {string}
 */
export const formatDateTime = date => {
  const zeroPadding = n => (n < 10 ? `0${n}` : n);
  const { year, month, day, hour, minutes } = {
    year: date.getFullYear(),
    month: zeroPadding(date.getMonth() + 1),
    day: zeroPadding(date.getDate()),
    hour: zeroPadding(date.getHours()),
    minutes: zeroPadding(date.getMinutes()),
  };

  return `${year}-${month}-${day} ${hour}:${minutes}:00`;
};

// generates an absolute, needed in case of running Foreman from a subpath
export const foremanUrl = path => {
  deprecate('foremanUrl', 'plain URL', 3.1);
  return path;
};

export default {
  isoCompatibleDate,
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
  deepPropsToCamelCase,
  deepPropsToSnakeCase,
  stringIsPositiveNumber,
  getManualURL,
  formatDate,
  formatDateTime,
  foremanUrl,
  getWikiURL,
};
