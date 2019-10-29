import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';
import {
  selectNotifications,
  selectIsDrawerOpen,
  selectIsReady,
  selectHasUnreadMessages,
  selectExpandedGroup,
} from '../NotificationsSelectors';
import { stateWithNotifications } from '../Notifications.fixtures';

const state = stateWithNotifications;

const fixtures = {
  'should return Notifications': () => selectNotifications(state),
  'should return Notifications isDrawerOpen': () => selectIsDrawerOpen(state),
  'should return Notifications expandedGroup': () => selectExpandedGroup(state),
  'should return Notifications hasUnreadMessages': () =>
    selectHasUnreadMessages(state),
  'should return Notifications isReady': () => selectIsReady(state),
};

describe('Notifications selectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
