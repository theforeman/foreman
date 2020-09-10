import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  TEST_DATA_RESOLVED,
  TEST_DATA_FAILED,
  TEST_HIDE_LOADING,
  TEST_CLEAR_ERROR,
  TEST_SHOW_LOADING,
} from './constants';
import withDataReducer from '../withDataReducer';

export const dataReducer = withDataReducer('TEST');

const fixtures = {
  'should return the initial state': {},
  'should handle TEST_SHOW_LOADING': {
    action: {
      type: TEST_SHOW_LOADING,
    },
  },
  'should handle TEST_HIDE_LOADING': {
    action: {
      type: TEST_HIDE_LOADING,
    },
  },
  'should handle TEST_CLEAR_ERROR': {
    action: {
      type: TEST_CLEAR_ERROR,
    },
  },
  'should handle TEST_DATA_RESOLVED': {
    action: {
      type: TEST_DATA_RESOLVED,
      payload: {
        testData: 'testData',
        isLoading: false,
        hasData: true,
      },
    },
  },
  'should handle TEST_DATA_FAILED': {
    action: {
      type: TEST_DATA_FAILED,
      payload: {
        message: { type: 'error', text: 'some-error' },
      },
    },
  },
};

describe('withDataReducer', () =>
  testReducerSnapshotWithFixtures(dataReducer, fixtures));
