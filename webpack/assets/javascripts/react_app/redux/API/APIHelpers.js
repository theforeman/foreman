import { API_OPERATIONS } from './APIConstants';
import { API } from './';

export const getApiMethodByActionType = type => type.substring(4).toLowerCase();

export const getApiResponse = async ({ type, url, headers, params }) => {
  const method = getApiMethodByActionType(type);
  switch (method) {
    case 'get':
      return API[method](url, headers, params);
    case 'delete':
      return API[method](url, headers);
    default:
      return API[method](url, params, headers);
  }
};

export const isAPIAction = ({ type }) =>
  Object.values(API_OPERATIONS).includes(type);

const HTML_BODY = /^\s*</;

const asArray = value => {
  if (value == null || value === '') return [];
  return Array.isArray(value) ? value : [value];
};

const flattenFieldErrors = errors => {
  if (!errors || typeof errors !== 'object' || Array.isArray(errors)) {
    return { messages: [], fieldErrors: {} };
  }
  const fieldErrors = {};
  const messages = [];
  Object.entries(errors).forEach(([field, vals]) => {
    const list = asArray(vals)
      .filter(Boolean)
      .map(String);
    if (list.length) {
      fieldErrors[field] = list;
      messages.push(...list);
    }
  });
  return { messages, fieldErrors };
};

const unwrap = input => {
  if (input.response) {
    return {
      status: input.response.status,
      body: input.response.data,
      axiosError: input,
    };
  }
  if (input.status !== undefined) {
    return { status: input.status, body: input.data, axiosError: undefined };
  }
  return { status: undefined, body: input, axiosError: undefined };
};

/**
 * @typedef {Object} APIErrorParsed
 * @property {string|undefined} message Comma-joined summary suitable for toasts.
 * @property {string[]} messages Individual messages in parser priority order.
 * @property {Object.<string, string[]>} fieldErrors Validation messages keyed by field.
 * @property {number|undefined} status HTTP status when available.
 * @property {*} [body] Unwrapped response body or raw input fragment.
 */

/**
 * Normalize known API failure payloads into {@link APIErrorParsed}.
 *
 * Bounded helper for existing Foreman and legacy plugin shapes (Foreman v2 `error`,
 * Katello-style `message` / `errors`, JSON:API `errors[]`, HTML/transport fallbacks).
 * Not an extensible adapter: do not add new error schemas here — use established API
 * responses or handle a fixed contract at the call site. See `developer_docs/api-error-parsing.asciidoc`
 * and `__tests__/APIHelpers.test.js` for the contract.
 *
 * @param {Object|string|undefined|null} input Axios error, `{ status, data }`, JSON body, or string.
 * @returns {APIErrorParsed}
 */
export const parseAPIError = input => {
  const empty = {
    message: undefined,
    messages: [],
    fieldErrors: {},
    status: undefined,
    body: undefined,
  };
  if (input == null) return empty;
  if (typeof input === 'string') {
    return { ...empty, message: input, messages: [input], body: input };
  }

  const { status, body, axiosError } = unwrap(input);

  if (typeof body === 'string') {
    if (HTML_BODY.test(body)) {
      const fallback =
        axiosError?.message ||
        (status ? `Request failed with status code ${status}` : '');
      return {
        ...empty,
        message: fallback || undefined,
        messages: fallback ? [fallback] : [],
        status,
        body,
      };
    }
    return { ...empty, message: body, messages: [body], status, body };
  }

  if (!body || typeof body !== 'object') {
    const fallback =
      axiosError?.message ||
      (status ? `Request failed with status code ${status}` : undefined);
    return {
      ...empty,
      message: fallback,
      messages: fallback ? [fallback] : [],
      status,
      body,
    };
  }

  const errorObj = body.error;
  let messages = [];
  let fieldErrors = {};

  if (errorObj && typeof errorObj === 'object') {
    messages = asArray(errorObj.full_messages)
      .filter(Boolean)
      .map(String);
    if (!messages.length && errorObj.message) {
      messages = [String(errorObj.message)];
      if (errorObj.details) messages.push(String(errorObj.details));
    }
    const {
      fieldErrors: nestedFieldErrors,
      messages: nestedMessages,
    } = flattenFieldErrors(errorObj.errors);
    fieldErrors = nestedFieldErrors;
    if (!messages.length) messages = nestedMessages;
  } else if (typeof errorObj === 'string' && errorObj) {
    messages = [errorObj];
  }

  if (!messages.length && (body.message || body.displayMessage)) {
    messages = asArray(body.message || body.displayMessage)
      .filter(Boolean)
      .map(String);
  }

  if (!messages.length && Array.isArray(body.errors)) {
    if (body.errors.some(item => item && typeof item === 'object')) {
      messages = body.errors
        .map(item => item?.detail || item?.title)
        .filter(Boolean)
        .map(String);
    } else {
      messages = body.errors.filter(Boolean).map(String);
    }
  }

  if (!messages.length && body.errors && typeof body.errors === 'object') {
    const {
      messages: flattenedMessages,
      fieldErrors: flattenedFieldErrors,
    } = flattenFieldErrors(body.errors);
    messages = flattenedMessages;
    fieldErrors = { ...fieldErrors, ...flattenedFieldErrors };
  }

  if (!messages.length && axiosError?.message) {
    messages = [axiosError.message];
  }

  return {
    message: messages.join(', ') || undefined,
    messages,
    fieldErrors,
    status,
    body,
  };
};

/**
 * @param {Object|string|undefined|null} input Same as {@link parseAPIError}.
 * @returns {string[]} Message list (empty when none found).
 */
export const getAPIErrorMessages = input => parseAPIError(input).messages;

/**
 * @param {Object|string|undefined|null} input Same as {@link parseAPIError}.
 * @returns {string|undefined} Single-line summary for toasts and simple UI.
 */
export const getAPIErrorMessage = input => parseAPIError(input).message;
