import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import ModelDeleteModal from './ModelDeleteModal';

const fixtures = {
  'should render a modal': {
    fetchAndPush: jest.fn(),
    toDelete: {
      name: 'HW model to delete',
      id: 5,
    },
  },
};

describe('ModelDeleteModal', () => {
  testComponentSnapshotsWithFixtures(ModelDeleteModal, fixtures);
});
