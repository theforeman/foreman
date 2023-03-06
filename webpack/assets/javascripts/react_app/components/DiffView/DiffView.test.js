import { fixtures } from './Diff.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

import DiffView from './DiffView';

describe('DiffView', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(DiffView, fixtures));
});
