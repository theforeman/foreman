import {
  AUTO_COMPLETE_REQUEST,
  AUTO_COMPLETE_SUCCESS,
  AUTO_COMPLETE_FAILURE,
  AUTO_COMPLETE_RESET,
} from '../AutoCompleteConstants';
import reducer from '../AutoCompleteReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import * as mock from '../AutoComplete.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should update state with initial data': {
    action: {
      type: AUTO_COMPLETE_SUCCESS,
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
};

describe('AutoComplete reducer', () => testReducerSnapshotWithFixtures(reducer, fixtures));
