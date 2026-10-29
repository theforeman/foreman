import {
  selectAPI,
  selectAPIByKey,
  selectAPIStatus,
  selectAPIError,
  selectAPIErrorMessage,
  selectAPIHttpStatus,
  selectAPIResponse,
  selectAPIPayload,
} from '../APISelectors';
import { key, payload, data, error } from '../APIFixtures';
import { STATUS } from '../../../constants';

const apiError = {
  message: 'Request failed with status code 404',
  response: {
    status: 404,
    data: { error: { message: 'Record not found' } },
  },
};

const fullMessagesError = {
  message: 'Request failed with status code 422',
  response: {
    status: 422,
    data: { error: { full_messages: ['Name has already been taken'] } },
  },
};

const successState = {
  API: {
    [key]: {
      payload,
      response: data,
      status: STATUS.RESOLVED,
    },
  },
};

const failureState = {
  API: {
    [key]: {
      payload,
      response: error,
      status: STATUS.ERROR,
    },
  },
};

const axiosFailureState = {
  API: {
    [key]: {
      payload,
      response: apiError,
      status: STATUS.ERROR,
    },
  },
};

const fullMessagesFailureState = {
  API: {
    [key]: {
      payload,
      response: fullMessagesError,
      status: STATUS.ERROR,
    },
  },
};

describe('API selectors', () => {
  it('should return the API wrapper', () => {
    expect(selectAPI(successState)).toEqual({
      [key]: {
        payload,
        response: data,
        status: STATUS.RESOLVED,
      },
    });
  });

  it('should return the API substate by key', () => {
    expect(selectAPIByKey(successState, key)).toEqual({
      payload,
      response: data,
      status: STATUS.RESOLVED,
    });
  });

  it('should return the API substate status', () => {
    expect(selectAPIStatus(successState, key)).toBe(STATUS.RESOLVED);
  });

  it('should return the API substate response', () => {
    expect(selectAPIResponse(successState, key)).toEqual(data);
  });

  it('should return the API substate payload', () => {
    expect(selectAPIPayload(successState, key)).toEqual(payload);
  });

  it('should return the API substate error', () => {
    expect(selectAPIError(failureState, key)).toEqual(error);
  });

  it('should return the API substate error message', () => {
    expect(selectAPIErrorMessage(failureState, key)).toBe('some_error');
  });

  it('should return the API error message from an axios response body', () => {
    expect(selectAPIErrorMessage(axiosFailureState, key)).toBe(
      'Record not found'
    );
  });

  it('should return full_messages via getAPIErrorMessage', () => {
    expect(selectAPIErrorMessage(fullMessagesFailureState, key)).toBe(
      'Name has already been taken'
    );
  });

  it('should return the API HTTP status from an axios error', () => {
    expect(selectAPIHttpStatus(axiosFailureState, key)).toBe(404);
  });

  it('should return undefined HTTP status when there is no API error', () => {
    expect(selectAPIHttpStatus(successState, key)).toBeUndefined();
  });

  it('should return empty object for unknown key payload', () => {
    expect(selectAPIPayload(successState, 'UNKNOWN')).toEqual({});
  });

  it('should return empty object for unknown key response', () => {
    expect(selectAPIResponse(successState, 'UNKNOWN')).toEqual({});
  });

  it('should return null error when status is not ERROR', () => {
    expect(selectAPIError(successState, key)).toBeNull();
  });

  it('should return undefined error message when status is not ERROR', () => {
    expect(selectAPIErrorMessage(successState, key)).toBeUndefined();
  });
});
