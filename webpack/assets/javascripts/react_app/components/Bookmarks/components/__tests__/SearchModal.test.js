import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import SearchModal from '../SearchModal';

const props = {
  controller: 'hosts',
  url: '/api/bookmarks',
  title: 'Create Bookmark',
  onEnter: jest.fn(),
  setModalClosed: jest.fn(),
};

const fixtures = {
  'should show search modal': {
    ...props,
  },
};

describe('SearchModal', () =>
  testComponentSnapshotsWithFixtures(SearchModal, fixtures));
