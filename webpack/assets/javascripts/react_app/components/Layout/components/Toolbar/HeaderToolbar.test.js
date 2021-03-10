import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import { hasTaxonomiesMock } from '../../Layout.fixtures';
import { noop } from '../../../../common/helpers';

import HeaderToolbar from './HeaderToolbar';

const fixtures = {
  'render HeaderToolbar': {
    ...hasTaxonomiesMock.data,
    currentLocation: hasTaxonomiesMock.currentLocation,
    currentOrganization: hasTaxonomiesMock.currentOrganization,
    isLoading: false,
    changeActiveMenu: noop,
  },
};

describe('HeaderToolbar', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(HeaderToolbar, fixtures));
});
