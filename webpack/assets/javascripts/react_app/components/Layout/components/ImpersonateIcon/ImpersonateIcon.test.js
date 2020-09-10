import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import ImpersonateIcon from './ImpersonateIcon';

const fixtures = {
  'should render': {
    stopImpersonationUrl: '/stop_impersonation',
    stopImpersonating: () => {},
  },
};

describe('ImpersonateIcon', () =>
  testComponentSnapshotsWithFixtures(ImpersonateIcon, fixtures));
