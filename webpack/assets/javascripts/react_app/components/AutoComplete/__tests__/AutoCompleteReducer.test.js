import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
  AUTO_COMPLETE_INIT,
  AUTO_COMPLETE_DISABLED_CHANGE,
  AUTO_COMPLETE_CONTROLLER_CHANGE,
} from '../AutoCompleteConstants';
import reducer from '../AutoCompleteReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import * as mock from '../AutoComplete.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should update state with initial data': {
    action: {
      type: AUTO_COMPLETE_INIT,
      payload: mock.initialValues,
    },
  },
  'should handle AUTO_COMPLETE_RESET': {
    action: {
      type: AUTO_COMPLETE_RESET,
      payload: mock.initialState,
    },
  },
  'should handle AUTO_COMPLETE_REQUEST': {
    action: {
      type: AUTO_COMPLETE_REQUEST,
      payload: mock.request,
    },
  },
  'should handle AUTO_COMPLETE_SUCCESS': {
    action: {
      type: AUTO_COMPLETE_SUCCESS,
      payload: mock.success,
    },
  },
  'should handle AUTO_COMPLETE_FAILURE': {
    action: {
      type: AUTO_COMPLETE_FAILURE,
      payload: mock.failure,
    },
  },
  'should handle AUTO_COMPLETE_DISABLED_CHANGE': {
    action: {
      type: AUTO_COMPLETE_DISABLED_CHANGE,
      payload: mock.disabledChange,
    },
  },
  'should handle AUTO_COMPLETE_CONTROLLER_CHANGE': {
    action: {
      type: AUTO_COMPLETE_CONTROLLER_CHANGE,
      payload: mock.controllerChange,
    },
  },
};

describe('AutoComplete reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
