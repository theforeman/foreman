import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

import ImpersonateIcon from './ImpersonateIcon';

const fixtures = {
  'should render': {
    stopImpersonationUrl: '/stop_impersonation',
    stopImpersonating: () => {},
  },
};

describe('ImpersonateIcon', () =>
  testComponentSnapshotsWithFixtures(ImpersonateIcon, fixtures));
