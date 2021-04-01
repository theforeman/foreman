import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  patternflyMenuItemsSelector,
  selectIsLoading,
  selectLayout,
  selectCurrentLocation,
  selectCurrentOrganization,
  selectIsNavOpen,
} from '../LayoutSelectors';
import { layoutMock, hashItemNameless } from '../Layout.fixtures';

const state = {
  layout: {
    items: layoutMock.data.menu,
    currentOrganization: { title: 'org1' },
    currentLocation: { title: 'loc1' },
    isLoading: true,
    isNavOpen: false,
  },
};

const emptyState = {
  layout: {
    items: [],
  },
};

const namelessState = {
  layout: {
    items: hashItemNameless,
    currentOrganization: { title: 'org1' },
    currentLocation: { title: 'loc1' },
    isLoading: true,
  },
};

const fixtures = {
  'should return Layout': () => selectLayout(state),
  'should return PF-React Compatible items': () =>
    patternflyMenuItemsSelector(state),
  'should return empty array of items': () =>
    patternflyMenuItemsSelector(emptyState),
  'should filter out nameless items': () =>
    patternflyMenuItemsSelector(namelessState),

  'should return isLoading from selector': () => selectIsLoading(state),
  'should return location from selector': () => selectCurrentLocation(state),
  'should return organization from selector': () =>
    selectCurrentOrganization(state),
  'should return isNavOpen from selector': () => selectIsNavOpen(state),
};

describe('Layout selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
