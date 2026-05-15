import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
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

const fixtures = {
  'should return the API wrapper': () => selectAPI(successState),
  'should return the API substate by key': () =>
    selectAPIByKey(successState, key),
  'should return the API substate status': () =>
    selectAPIStatus(successState, key),
  'should return the API substate response': () =>
    selectAPIResponse(successState, key),
  'should return the API substate payload': () =>
    selectAPIPayload(successState, key),
  'should return the API substate error': () =>
    selectAPIError(failureState, key),
  'should return the API substate error message': () =>
    selectAPIErrorMessage(failureState, key),
  'should return the API error message from an axios response body': () =>
    selectAPIErrorMessage(axiosFailureState, key),
  'should return the API HTTP status from an axios error': () =>
    selectAPIHttpStatus(axiosFailureState, key),
  'should return undefined HTTP status when there is no API error': () =>
    selectAPIHttpStatus(successState, key),
};

describe('API selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
