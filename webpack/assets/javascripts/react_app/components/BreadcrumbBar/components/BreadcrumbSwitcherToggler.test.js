import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import BreadcrumbSwitcherToggler from './BreadcrumbSwitcherToggler';

const fixtures = {
  'render a BreadcrumbSwitcherToggler': {
    onClick: jest.fn(),
  },
};

describe('BreadcrumbSwitcherToggler', () =>
  testComponentSnapshotsWithFixtures(BreadcrumbSwitcherToggler, fixtures));
