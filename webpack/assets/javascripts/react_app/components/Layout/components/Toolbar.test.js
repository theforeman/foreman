import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { hasTaxonomiesMock } from '../Layout.fixtures';

import Toolbar from './Toolbar';

const fixtures = {
  'render Toolbar': {
    data: hasTaxonomiesMock.data,
    currentLocation: hasTaxonomiesMock.currentLocation,
    changeLocation: () => {},
    currentOrganization: hasTaxonomiesMock.currentOrganization,
    changeOrganization: () => {},
    isLoading: false,
    changeActiveMenu: () => {},
  },
};

describe('Toolbar', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(Toolbar, fixtures));
});
