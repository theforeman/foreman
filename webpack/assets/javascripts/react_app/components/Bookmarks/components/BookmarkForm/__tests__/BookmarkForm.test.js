import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import BookmarkForm from '../BookmarkForm';

const props = {
  controller: 'hosts',
  url: '/api/bookmarks',
  onCancel: () => {},
  submitForm: () => {},
  initialValues: { public: true, query: 'my query', name: 'my bookmark' },
  setModalClosed: jest.fn(),
};

const fixtures = {
  'should render bookmarks form with initial values': {
    ...props,
  },
};

describe('BookmarkForm', () =>
  testComponentSnapshotsWithFixtures(BookmarkForm, fixtures));
