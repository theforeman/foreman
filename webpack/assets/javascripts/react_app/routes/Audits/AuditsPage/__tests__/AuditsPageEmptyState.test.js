import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

import AuditsPageEmptyState from '../AuditsPageEmptyState';

const fixtures = {
  'render AuditsPageEmptyState w/error': {
    message: { type: 'error', text: 'error' },
  },
  'render AuditsPageEmptyState w/empty': {
    message: { type: 'empty', text: 'empty' },
  },
};

describe('AuditsPageEmptyState', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(AuditsPageEmptyState, fixtures));
});
