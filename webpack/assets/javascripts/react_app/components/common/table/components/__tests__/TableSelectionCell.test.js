import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import TableSelectionCell from '../TableSelectionCell';

const fixtures = {
  'renders TableSelectionCell': {
    id: 'some id',
    label: 'some label',
    checked: true,
    onChange: jest.fn(),
  },
};

describe('TableSelectionCell', () =>
  testComponentSnapshotsWithFixtures(TableSelectionCell, fixtures));
