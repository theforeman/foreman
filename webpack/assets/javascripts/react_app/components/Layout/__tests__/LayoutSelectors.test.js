import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  patternflyMenuItemsSelector,
  selectIsLoading,
  selectLayout,
  selectCurrentLocation,
  selectCurrentOrganization,
} from '../LayoutSelectors';
import { layoutMock } from '../Layout.fixtures';

const state = {
  layout: {
    items: layoutMock.data.menu,
    activeMenu: 'Hosts',
    currentOrganization: { title: 'org1' },
    currentLocation: { title: 'loc1' },
    isLoading: true,
  },
};

const emptyState = {
  layout: {
    items: [],
  },
};

const fixtures = {
  'should return Layout': () => selectLayout(state),
  'should return PF-React Compatible items': () =>
    patternflyMenuItemsSelector(state),
  'should return empty array of items': () =>
    patternflyMenuItemsSelector(emptyState),

  'should return isLoading from selector': () => selectIsLoading(state),
  'should return location from selector': () => selectCurrentLocation(state),
  'should return organization from selector': () =>
    selectCurrentOrganization(state),
};

describe('Layout selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
