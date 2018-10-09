import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import Breadcrumb from './Breadcrumb';
import {
  breadcrumbItems,
  breadcrumbTitleItems,
  breadcrumbsWithReplacementTitle,
} from '../BreadcrumbBar.fixtures';

const fixtures = {
  'renders breadcrumbs menu': breadcrumbItems,
  'renders h1 title': breadcrumbTitleItems,
  'renders title override': breadcrumbsWithReplacementTitle,
};

describe('Breadcrumbs', () =>
  testComponentSnapshotsWithFixtures(Breadcrumb, fixtures));
