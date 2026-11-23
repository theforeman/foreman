import { testSelectorsSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  patternflyMenuItemsSelector,
  selectIsLoading,
  selectLayout,
  selectCurrentLocation,
  selectCurrentOrganization,
} from '../LayoutSelectors';
import { layoutMock, hashItemNameless } from '../Layout.fixtures';

const state = {
  layout: {
    items: layoutMock.data.menu,
    currentOrganization: 'org1',
    currentLocation: 'loc1',
    isLoading: true,
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
    currentOrganization: 'org1',
    currentLocation: 'loc1',
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
};

describe('Layout selectors', () => testSelectorsSnapshotWithFixtures(fixtures));
