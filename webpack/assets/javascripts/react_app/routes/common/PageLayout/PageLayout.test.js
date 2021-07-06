import React from 'react';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import PageLayout from './PageLayout';
import { pageLayoutMock } from './PageLayout.fixtures';

jest.unmock('react-helmet');

const pageLayoutFixtures = {
  'render pageLayout w/search': pageLayoutMock,
  'render pageLayout without search': { ...pageLayoutMock, searchable: false },
  'render pageLayout with custom breadcrumbs': {
    ...pageLayoutMock,
    customBreadcrumbs: <p>customBreadcrumbs</p>,
  },
  'render pageLayout without breadcrumbs': {
    ...pageLayoutMock,
    breadcrumbOptions: null,
  },
  'render pageLayout w/toolBar': {
    ...pageLayoutMock,
    toolbarButtons: <button>toolbarButton</button>,
  },
  'render pageLayout w/beforeToolbarComponent': {
    ...pageLayoutMock,
    beforeToolbarComponent: <p>beforeToolbarComponent</p>,
  },
};

testComponentSnapshotsWithFixtures(PageLayout, pageLayoutFixtures);
