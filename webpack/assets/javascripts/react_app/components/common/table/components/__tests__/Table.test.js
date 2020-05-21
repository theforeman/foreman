import { testComponentSnapshotsWithFixtures } from '../../../../../common/testHelpers';

import Table from '../Table';
import { columnsFixtures, rowsFixtures } from '../TableFixtures';

const fixtures = {
  'renders Table with children': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    children: 'some children',
  },
  'renders Table with body': {
    columns: columnsFixtures,
    rows: rowsFixtures,
    bodyMessage: 'some body message',
  },
};

describe('Table', () => testComponentSnapshotsWithFixtures(Table, fixtures));
