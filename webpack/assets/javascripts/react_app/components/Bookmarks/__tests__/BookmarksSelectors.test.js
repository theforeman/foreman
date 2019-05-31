import { testSelectorsSnapshotWithFixtures } from 'react-redux-test-utils';

import {
  selectBookmarksShowModal,
  selectBookmarksStatus,
  selectBookmarksResults,
  selectBookmarksErrors,
} from '../BookmarksSelectors';

import { bookmarks } from '../Bookmarks.fixtures';

import { STATUS } from '../../../constants';

const controller = 'hosts';

const stateFactory = () => ({
  bookmarks: {
    showModal: false,
    currentQuery: 'my query',
    [controller]: {
      results: bookmarks,
      errors: 'my errors',
      status: STATUS.RESOLVED,
    },
  },
});

const fixtures = {
  'should return if modal shown': () =>
    selectBookmarksShowModal(stateFactory()),
  'should return status': () =>
    selectBookmarksStatus(stateFactory(), controller),
  'should return results': () =>
    selectBookmarksResults(stateFactory(), controller),
  'should return error': () =>
    selectBookmarksErrors(stateFactory(), controller),
};

describe('BookmarksSelectors', () =>
  testSelectorsSnapshotWithFixtures(fixtures));
