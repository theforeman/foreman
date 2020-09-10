import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import UserDropdowns from './UserDropdowns';
import { userDropdownProps } from '../Layout.fixtures';

const fixtures = {
  render: userDropdownProps,
  'render with impersonated by icon': {
    ...userDropdownProps,
    user: { ...userDropdownProps.user, impersonated_by: true },
  },
};
describe('UserDropdown', () =>
  testComponentSnapshotsWithFixtures(UserDropdowns, fixtures));
