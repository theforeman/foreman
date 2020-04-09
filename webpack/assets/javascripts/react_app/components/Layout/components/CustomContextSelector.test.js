import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { hasTaxonomiesMock } from '../Layout.fixtures';

import CustomContextSelector from './CustomContextSelector';

const fixtures = {
  'render CustomContextSelector': {
    toggleText: hasTaxonomiesMock.currentOrganization,
    onSearchInputChange: () => {},
    isOpen: true,
    searchInputValue: '',
    onToggle: () => {},
    onSelect: () => {},
    onSearchButtonClick: () => {},
    screenReaderLabel: 'Selected Taxonomy:',
    showFilter: hasTaxonomiesMock.data.orgs.available_organizations.length > 6,
    staticGroup: {
      title: 'Organization',
      items: [
        {
          title: 'Any Organization',
          href: '/organizations/clear',
          onClick: () => {},
        },
        {
          title: 'Manage Organizations',
          href: '/organizations',
        },
      ],
    },
  },
};

describe('CustomContextSelector', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(CustomContextSelector, fixtures));
});
