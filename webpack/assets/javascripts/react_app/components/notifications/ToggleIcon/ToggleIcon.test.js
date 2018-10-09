import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import ToggleIcon from './ToggleIcon';

const fixtures = {
  'render ToggleIcon': {},
  'render ToggleIcon with unread-messages': { hasUnreadMessages: true },
};

describe('ToggleIcon', () =>
  testComponentSnapshotsWithFixtures(ToggleIcon, fixtures));
