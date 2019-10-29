import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import Notifications from '../Notifications';

const fixtures = {
  'render without Props': {},
  /** fixtures, props for the component */
};

describe('Notifications', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Notifications, fixtures));
});
