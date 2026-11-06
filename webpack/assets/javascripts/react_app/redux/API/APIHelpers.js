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
  if (input == null || typeof input === 'string') {
    return { status: undefined, body: input, axiosError: undefined };
  }
  if (input.response) {
    return {
      status: input.response.status,
      body: input.response.data,
      axiosError: input,
    };
  }
  if (input.data !== undefined && input.status !== undefined) {
    return { status: input.status, body: input.data, axiosError: undefined };
  }
  return { status: undefined, body: input, axiosError: undefined };
};

/**
 * Normalize API failure payloads into a consistent shape.
 * Accepts an Axios error, Axios response, unwrapped body, string, or undefined.
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
    const fallback = axiosError?.message;
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

export const getAPIErrorMessages = input => parseAPIError(input).messages;
export const getAPIErrorMessage = input => parseAPIError(input).message;
