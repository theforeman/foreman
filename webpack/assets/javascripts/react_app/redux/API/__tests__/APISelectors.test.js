import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectAPI,
  selectAPIByKey,
  selectAPIStatus,
  selectAPIError,
  selectAPIErrorMessage,
  selectAPIResponse,
  selectAPIPayload,
  selectAPITimestamp,
} from '../APISelectors';
import { key, payload, data, error } from '../APIFixtures';
import { STATUS } from '../../../constants';

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

const withTimestamp = {
  API: {
    [key]: {
      payload: { timestamp: 10000 }
    }
  }
}
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
  'should return the API current timestamp': () =>
    selectAPITimestamp(withTimestamp, key),
};

describe('API selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
