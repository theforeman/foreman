import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectAPI,
  selectAPIByKey,
  selectAPIStatus,
  selectAPIError,
  selectAPIErrorMessage,
  selectAPIResponse,
  selectAPIPayload,
  selectIsFirstRequest,
} from '../APISelectors';
import { key, payload, data, error } from '../APIFixtures';
import { STATUS } from '../../../constants';

const successState = {
  API: {
    [key]: {
      payload,
      response: data,
      status: STATUS.RESOLVED,
      isFirstRequest: true,
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
  'should return the API substate isFirstRequest': () =>
    selectIsFirstRequest(successState, key),
  'should return the API substate error': () =>
    selectAPIError(failureState, key),
  'should return the API substate error message': () =>
    selectAPIErrorMessage(failureState, key),
};

describe('API selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
