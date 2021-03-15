import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import UserDropdowns from './UserDropdowns';
import { userDropdownProps } from '../../Layout.fixtures';

const fixtures = {
  render: userDropdownProps,
};
describe('UserDropdown', () =>
  testComponentSnapshotsWithFixtures(UserDropdowns, fixtures));
