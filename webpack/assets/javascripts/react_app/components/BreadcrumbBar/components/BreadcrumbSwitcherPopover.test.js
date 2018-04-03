import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbSwitcherPopover from './BreadcrumbSwitcherPopover';
import {
  breadcrumbSwitcherLoading,
  breadcrumbSwitcherLoaded,
  breadcrumbSwitcherLoadedWithPagination,
} from '../BreadcrumbBar.fixtures';

const fixtures = {
  'render loading state': { id: 'some-id', ...breadcrumbSwitcherLoading },
  'render resources list': { id: 'some-id', ...breadcrumbSwitcherLoaded },
  'render resources list with pagination': {
    id: 'some-id',
    ...breadcrumbSwitcherLoadedWithPagination,
  },
};

describe('BreadcrumbSwitcherPopover', () =>
  testComponentSnapshotsWithFixtures(BreadcrumbSwitcherPopover, fixtures));
