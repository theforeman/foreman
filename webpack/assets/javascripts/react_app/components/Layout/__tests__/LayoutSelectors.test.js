import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  selectActiveMenu,
  patternflyMenuItemsSelector,
  selectIsLoading,
  selectLayout,
  selectCurrentLocation,
  selectCurrentOrganization,
  selectIsCollapsed,
} from '../LayoutSelectors';
import { layoutMock, hashItemNameless } from '../Layout.fixtures';

const state = {
  layout: {
    items: layoutMock.data.menu,
    activeMenu: 'Hosts',
    currentOrganization: { title: 'org1' },
    currentLocation: { title: 'loc1' },
    isLoading: true,
    isCollapsed: false,
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
    activeMenu: 'Empty',
    currentOrganization: { title: 'org1' },
    currentLocation: { title: 'loc1' },
    isLoading: true,
    isCollapsed: false,
  },
};

const fixtures = {
  'should return Layout': () => selectLayout(state),
  'should return activeMenu': () => selectActiveMenu(state),
  'should return PF-React Compatible items': () =>
    patternflyMenuItemsSelector(state),
  'should return empty array of items': () =>
    patternflyMenuItemsSelector(emptyState),
  'should filter out nameless items': () =>
    patternflyMenuItemsSelector(namelessState),

  'should return isLoading from selector': () => selectIsLoading(state),
  'should return isCollapsed from selector': () => selectIsCollapsed(state),
  'should return location from selector': () => selectCurrentLocation(state),
  'should return organization from selector': () =>
    selectCurrentOrganization(state),
};

describe('Layout selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
