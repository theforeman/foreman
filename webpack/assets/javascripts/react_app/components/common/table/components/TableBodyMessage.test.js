import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import TableBodyMessage from './TableBodyMessage';

const fixtures = {
  'renders TableBodyMessage': {
    colSpan: 2,
    children: 'some children',
  },
};

describe('TableBodyMessage', () =>
  testComponentSnapshotsWithFixtures(TableBodyMessage, fixtures));
