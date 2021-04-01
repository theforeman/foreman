import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { hasTaxonomiesMock } from '../Layout.fixtures';

import VerticalNav from './VerticalNav';

const fixtures = {
  'render VerticalNav': {
    history: hasTaxonomiesMock.history,
    items: hasTaxonomiesMock.items,
  },
};

describe('VerticalNav', () =>
  testComponentSnapshotsWithFixtures(VerticalNav, fixtures));
