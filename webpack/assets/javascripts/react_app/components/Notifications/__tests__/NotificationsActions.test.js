import { testActionSnapshotWithFixtures } from 'react-redux-test-utils';
import { changeBool } from '../NotificationsActions';

const fixtures = {
  'should changeBool': () => changeBool({ bool: true }),
};

describe('Notifications actions', () =>
  testActionSnapshotWithFixtures(fixtures));
