import { radioMock } from './DiffView.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

import DiffRadioButtons from './DiffRadioButtons';

const fixtures = {
  'render DiffRadioButtons': radioMock,
};

describe('DiffView', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(DiffRadioButtons, fixtures));
});
