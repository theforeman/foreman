import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import PageLayout from './PageLayout';
import { pageLayoutMock } from './PageLayout.fixtures';

const pageLayoutFixtures = {
  'render pageLayout w/search': pageLayoutMock,
  'render pageLayout without search': { ...pageLayoutMock, searchable: false },
  'render pageLayout with custom breadcrumbs': {
    ...pageLayoutMock,
    customBreadcrumbs: 'customBreadcrumbs',
  },
  'render pageLayout without breadcrumbs': {
    ...pageLayoutMock,
    breadcrumbOptions: null,
  },
  'render pageLayout w/toastNotifications': {
    ...pageLayoutMock,
    toastNotifications: 'notification',
  },
  'render pageLayout w/toolBar': {
    ...pageLayoutMock,
    toolbarButtons: 'toolbarButton',
  },
  'render pageLayout w/beforeToolbarComponent': {
    ...pageLayoutMock,
    beforeToolbarComponent: 'beforeToolbarComponent',
  },
};

testComponentSnapshotsWithFixtures(PageLayout, pageLayoutFixtures);
