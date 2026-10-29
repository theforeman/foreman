import API from '../API';
import { API_OPERATIONS } from '../APIConstants';
import {
  getApiMethodByActionType,
  getApiResponse,
  getAPIErrorMessage,
  getAPIErrorMessages,
  isAPIAction,
  parseAPIError,
} from '../APIHelpers';
import { url, headers, params } from '../APIFixtures';

jest.mock('../API');

const axiosError = (status, data, message) => {
  const error = new Error(
    message || `Request failed with status code ${status}`
  );
  error.response = { status, data };
  return error;
};

describe('API helpers', () => {
  it('should return the right method based on a API_OPERATIONS type', () => {
    Object.keys(API_OPERATIONS).forEach(type => {
      expect(getApiMethodByActionType(API_OPERATIONS[type])).toEqual(
        type.toLowerCase()
      );
    });
  });

  it('should call API get', async () => {
    API.get.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.GET, url, headers, params });
    expect(API.get).toBeCalledWith(url, headers, params);
  });

  it('should call API post', async () => {
    API.post.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.POST, url, headers, params });
    expect(API.post).toBeCalledWith(url, params, headers);
  });

  it('should call API put', async () => {
    API.put.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.PUT, url, headers, params });
    expect(API.put).toBeCalledWith(url, params, headers);
  });

  it('should call API patch', async () => {
    API.patch.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.PATCH, url, headers, params });
    expect(API.patch).toBeCalledWith(url, params, headers);
  });

  it('should call API delete', async () => {
    API.delete.mockImplementation(async () => jest.fn());
    await getApiResponse({ type: API_OPERATIONS.DELETE, url, headers });
    expect(API.delete).toBeCalledWith(url, headers);
  });

  it('should call isAPIAction', async () => {
    Object.keys(API_OPERATIONS).forEach(type => {
      expect(isAPIAction({ type: API_OPERATIONS[type] })).toBeTruthy();
    });
  });
});

describe('parseAPIError', () => {
  it('returns empty result for omitted or null input', () => {
    expect(parseAPIError()).toEqual({
      message: undefined,
      messages: [],
      fieldErrors: {},
      status: undefined,
      body: undefined,
    });
    expect(parseAPIError(null)).toEqual({
      message: undefined,
      messages: [],
      fieldErrors: {},
      status: undefined,
      body: undefined,
    });
  });

  it('returns a string input as the message', () => {
    expect(parseAPIError('boom')).toEqual({
      message: 'boom',
      messages: ['boom'],
      fieldErrors: {},
      status: undefined,
      body: 'boom',
    });
  });

  it('prefers Foreman full_messages over Axios status text', () => {
    const error = axiosError(422, {
      error: { full_messages: ['Name has already been taken'] },
    });
    expect(getAPIErrorMessage(error)).toBe('Name has already been taken');
    expect(getAPIErrorMessage(error)).not.toMatch(/status code 422/);
  });

  it('joins multiple full_messages and filters empties', () => {
    const error = axiosError(422, {
      error: { full_messages: ['Name is taken', '', 'Email is invalid'] },
    });
    expect(getAPIErrorMessages(error)).toEqual([
      'Name is taken',
      'Email is invalid',
    ]);
    expect(getAPIErrorMessage(error)).toBe(
      'Name is taken, Email is invalid'
    );
  });

  it('uses error.message plus optional details', () => {
    const error = axiosError(500, {
      error: { message: 'Something failed', details: 'try again' },
    });
    expect(getAPIErrorMessages(error)).toEqual([
      'Something failed',
      'try again',
    ]);
  });

  it('handles string body.error', () => {
    expect(
      getAPIErrorMessage(axiosError(400, { error: 'not allowed' }))
    ).toBe('not allowed');
  });

  it('handles Katello message/errors and returns a string not an object', () => {
    const withMessage = axiosError(400, {
      message: 'CV publish failed',
      errors: ['ignored when message present'],
    });
    expect(typeof getAPIErrorMessage(withMessage)).toBe('string');
    expect(getAPIErrorMessage(withMessage)).toBe('CV publish failed');

    const errorsOnly = axiosError(400, {
      errors: ['first', 'second'],
    });
    expect(getAPIErrorMessage(errorsOnly)).toBe('first, second');
  });

  it('handles displayMessage', () => {
    expect(
      getAPIErrorMessage({ displayMessage: 'Friendly error' })
    ).toBe('Friendly error');
  });

  it('handles JSON:API errors[].detail', () => {
    expect(
      getAPIErrorMessage({
        errors: [{ detail: 'Invalid attribute' }, { title: 'Bad Request' }],
      })
    ).toBe('Invalid attribute, Bad Request');
  });

  it('flattens field hash errors', () => {
    const parsed = parseAPIError({
      error: { errors: { name: ['is taken'], base: 'cannot delete' } },
    });
    expect(parsed.fieldErrors).toEqual({
      name: ['is taken'],
      base: ['cannot delete'],
    });
    expect(parsed.message).toBe('is taken, cannot delete');
  });

  it('falls back to Axios message for HTML bodies', () => {
    const error = axiosError(
      500,
      '<html><body>Internal Server Error</body></html>'
    );
    expect(getAPIErrorMessage(error)).toBe(
      'Request failed with status code 500'
    );
  });

  it('accepts an Axios response or unwrapped body', () => {
    expect(
      getAPIErrorMessage({
        status: 422,
        data: { error: { full_messages: ['from response'] } },
      })
    ).toBe('from response');
    expect(
      getAPIErrorMessage({ error: { full_messages: ['from body'] } })
    ).toBe('from body');
  });

  it('falls back to Axios message when body has no usable messages', () => {
    const error = axiosError(404, {});
    expect(getAPIErrorMessage(error)).toBe(
      'Request failed with status code 404'
    );
  });
});
