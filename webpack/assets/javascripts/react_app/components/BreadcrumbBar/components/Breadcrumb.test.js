import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

import Breadcrumb from './Breadcrumb';
import { breadcrumbItems, breadcrumbTitleItems } from '../BreadcrumbBar.fixtures';

const fixtures = {
  'renders breadcrumbs menu': breadcrumbItems,
  'renders h1 title': breadcrumbTitleItems,
};

describe('Breadcrumbs', () => testComponentSnapshotsWithFixtures(Breadcrumb, fixtures));
