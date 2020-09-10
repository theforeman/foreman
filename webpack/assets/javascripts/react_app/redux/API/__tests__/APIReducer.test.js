import reducer from '../APIReducer';
import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import { middlewareActions } from '../APIFixtures';

const fixtures = {
  'should return the initial state': {},

  'should handle API request action': { action: middlewareActions.request },

  'should handle API success action': { action: middlewareActions.success },

  'should handle API failure action': { action: middlewareActions.failure },
};

describe('API reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
