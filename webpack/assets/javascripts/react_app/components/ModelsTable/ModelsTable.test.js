import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ModelsTable from './ModelsTable';

const results = [
  {
    info: null,
    created_at: '2018-03-26 09:54:21 +0300',
    updated_at: '2018-03-26 09:54:21 +0300',
    vendor_class: null,
    hardware_model: null,
    id: 29,
    name: 'X8SIL',
    can_edit: true,
    can_delete: true,
    hosts_count: 1,
  },
];

const fixtures = {
  'should render ModelsTable': {
    getTableItems: () => {},
    onDeleteClick: () => {},
    results,
  },
};

describe('ModelsTable', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(ModelsTable, fixtures));
});
