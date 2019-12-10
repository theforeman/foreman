import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import BookmarkForm from '../BookmarkForm';

const props = {
  controller: 'hosts',
  url: '/api/bookmarks',
  onCancel: () => {},
  submitForm: () => {},
  initialValues: { public: true, query: 'my query', name: 'my bookmark' },
};

const fixtures = {
  'should render bookmarks form with initial values': {
    ...props,
  },
};

describe('BookmarkForm', () =>
  testComponentSnapshotsWithFixtures(BookmarkForm, fixtures));
