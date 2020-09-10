import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import TableSelectionHeaderCell from '../TableSelectionHeaderCell';

const fixtures = {
  'renders TableSelectionHeaderCell': {
    id: 'some id',
    label: 'some label',
    checked: true,
    onChange: jest.fn(),
  },
};

describe('TableSelectionHeaderCell', () =>
  testComponentSnapshotsWithFixtures(TableSelectionHeaderCell, fixtures));
