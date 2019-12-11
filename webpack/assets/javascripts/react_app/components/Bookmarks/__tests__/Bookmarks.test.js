import { testComponentSnapshotsWithFixtures } from '@theforeman/test';

import Bookmarks from '../Bookmarks';
import { STATUS } from '../../../constants';

const commonFixture = {
  controller: 'architectures',
  onBookmarkClick: () => {},
  url: '/api/v2/architectures',
  documentationUrl: 'https://test-docs.com',
  canCreate: true,
  showModal: false,
  status: STATUS.PENDING,
  errors: null,
  bookmarks: [],
};

const fixtures = {
  'should render bookmarks dropdown when loading': {
    ...commonFixture,
  },
  'should render bookmarks dropdown when loaded': {
    ...commonFixture,
    status: STATUS.RESOLVED,
    bookmarks: [
      { name: 'my-bookmark', controller: 'architectures', query: 'name ~ 86' },
    ],
  },
  'should render when no bookmarks loaded': {
    ...commonFixture,
    status: STATUS.RESOLVED,
  },
  'should show error': {
    ...commonFixture,
    status: STATUS.ERROR,
    errors: 'Random test error',
  },
};

describe('Bookmarks', () =>
  testComponentSnapshotsWithFixtures(Bookmarks, fixtures));
