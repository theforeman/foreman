import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';
import { selectNotifications, selectBool } from '../NotificationsSelectors';

const state = {
  notifications: {
    bool: false,
  },
};

const fixtures = {
  'should return Notifications': () => selectNotifications(state),
  'should return Notifications bool': () => selectBool(state),
};

describe('Notifications selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
