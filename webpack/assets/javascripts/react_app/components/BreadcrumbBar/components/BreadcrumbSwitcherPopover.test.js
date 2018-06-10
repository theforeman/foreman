import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbSwitcherPopover from './BreadcrumbSwitcherPopover';
import {
  breadcrumbSwitcherLoading,
  breadcrumbSwitcherLoaded,
  breadcrumbSwitcherLoadedWithPagination,
  breadcrumbSwitcherLoadedWithSearchQuery,
} from '../BreadcrumbBar.fixtures';

const fixtures = {
  'render loading state': { id: 'some-id', ...breadcrumbSwitcherLoading },
  'render resources list': { id: 'some-id', ...breadcrumbSwitcherLoaded },
  'render resources list with pagination': {
    id: 'some-id',
    ...breadcrumbSwitcherLoadedWithPagination,
  },
  'render resources list with a search query': {
    id: 'some-id',
    ...breadcrumbSwitcherLoadedWithSearchQuery,
  },
};

describe('BreadcrumbSwitcherPopover', () =>
  testComponentSnapshotsWithFixtures(BreadcrumbSwitcherPopover, fixtures));
