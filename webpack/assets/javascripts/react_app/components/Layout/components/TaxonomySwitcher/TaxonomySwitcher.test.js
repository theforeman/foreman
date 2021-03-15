import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import TaxonomySwitcher from './TaxonomySwitcher';
import { layoutMock } from '../../Layout.fixtures';

const props = {
  organizations: layoutMock.data.orgs.available_organizations,
  locations: layoutMock.data.locations.available_locations,
  isLoading: true,
};

const fixtures = {
  'render TaxonomySwitcher': { ...props },
};

describe('TaxonomySwitcher', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TaxonomySwitcher, fixtures));
});
