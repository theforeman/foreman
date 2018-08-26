import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import TaxonomySwitcher from './TaxonomySwitcher';
import { layoutMock } from '../Layout.fixtures';

const props = {
  organizations: layoutMock.data.orgs.available_organizations,
  taxonomiesBool: layoutMock.data.taxonomies,
  locations: layoutMock.data.locations.available_locations,
  currentLocation: 'location',
  currentOrganization: 'organization',
  isLoading: true,
};

const fixtures = {
  'render TaxonomySwitcher': { ...props },
};

describe('TaxonomySwitcher', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(TaxonomySwitcher, fixtures));
});
