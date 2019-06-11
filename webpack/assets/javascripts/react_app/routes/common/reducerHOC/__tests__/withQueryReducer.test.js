import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import { TEST_UPDATE_QUERY } from './constants';
import withQueryReducer from '../withQueryReducer';

const queryReducer = withQueryReducer('TEST');

const fixtures = {
  'should return the initial state': {},
  'should handle TEST_UPDATE_QUERY': {
    action: {
      type: TEST_UPDATE_QUERY,
      payload: {
        page: 21,
        perPage: 20,
        searchQuery: 'search',
        itemCount: 20,
      },
    },
  },
};

describe('withQueryReducer', () =>
  testReducerSnapshotWithFixtures(queryReducer, fixtures));
