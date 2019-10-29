import { testReducerSnapshotWithFixtures } from 'react-redux-test-utils';

import { NOTIFICATIONS_CHANGE_BOOL } from '../NotificationsConstants';
import reducer from '../NotificationsReducer';

const fixtures = {
  'should return the initial state': {},
  'should handle NOTIFICATIONS_CHANGE_BOOL': {
    action: {
      type: NOTIFICATIONS_CHANGE_BOOL,
      payload: {
        bool: true,
      },
    },
  },
};

describe('Notifications reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
