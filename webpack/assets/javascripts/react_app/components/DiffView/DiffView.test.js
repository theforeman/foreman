import { diffMock } from './DiffView.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

import DiffView from './DiffView';

const fixtures = {
  'render DiffView': diffMock,
};

describe('DiffView', () => {
  describe('rendering', () => testComponentSnapshotsWithFixtures(DiffView, fixtures));
});
