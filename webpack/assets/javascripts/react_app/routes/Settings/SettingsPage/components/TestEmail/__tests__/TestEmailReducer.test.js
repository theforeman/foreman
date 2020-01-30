import { testReducerSnapshotWithFixtures } from '@theforeman/test';

import { TEST_EMAIL_REQUEST, TEST_EMAIL_RESPONSE } from '../TestEmailConstants';

import reducer from '../TestEmailReducer';

const fixtures = {
  'should return initial state': {},
  'should return email loading': {
    action: {
      type: TEST_EMAIL_REQUEST,
    },
  },
  'should return email stopped loading': {
    action: {
      type: TEST_EMAIL_RESPONSE,
    },
  },
};

describe('TestEmailReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
