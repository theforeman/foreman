import { diffMock, patchMock } from './DiffView.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

import DiffView from './DiffView';

const fixtures = {
  'render DiffView w/oldText & newText': diffMock,
  'render DiffView w/Patch': patchMock,
};

describe('DiffView', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(DiffView, fixtures));
});
