import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';

import SearchModal from '../SearchModal';

const props = {
  controller: 'hosts',
  show: true,
  url: '/api/bookmarks',
  onHide: () => {},
};

const fixtures = {
  'should not show search modal': {
    ...props,
    show: false,
  },
  'should show search modal': {
    ...props,
  },
};

describe('SearchModal', () =>
  testComponentSnapshotsWithFixtures(SearchModal, fixtures));
