import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import TableBodyMessage from '../TableBodyMessage';

const fixtures = {
  'renders TableBodyMessage': {
    colSpan: 2,
    children: 'some children',
  },
};

describe('TableBodyMessage', () =>
  testComponentSnapshotsWithFixtures(TableBodyMessage, fixtures));
