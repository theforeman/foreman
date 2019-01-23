import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import BreadcrumbSwitcherToggler from './BreadcrumbSwitcherToggler';

const fixtures = {
  'render a BreadcrumbSwitcherToggler': {
    onClick: jest.fn(),
  },
};

describe('BreadcrumbSwitcherToggler', () =>
  testComponentSnapshotsWithFixtures(BreadcrumbSwitcherToggler, fixtures));
