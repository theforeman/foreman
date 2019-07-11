import Immutable from 'seamless-immutable';
import { testReducerSnapshotWithFixtures } from '../../common/testHelpers';
import reducer, { initialState } from './ResourceErrorsReducer';
import {
  RESOURCE_ERRORS_RESOLVE,
  RESOURCE_ERRORS_RERUN,
} from './ResourceErrorsConstants';

const rerunState = Immutable({
  resolved: true,
  rerunAt: null,
  resources: {},
});

const fixtures = {
  'should handle RESOURCE_ERRORS_RESOLVE': {
    state: initialState,
    action: { type: RESOURCE_ERRORS_RESOLVE, payload: { resourceErrors: { name: "cannot be blank" } }}
  },
  'should handle RESOURCE_ERRORS_RERUN': {
    state: rerunState,
    action: { type: RESOURCE_ERRORS_RERUN, payload: { rerunAt: '2020-12-24' }}
  }
};

describe('ResourceErrorsReducer', () =>
    testReducerSnapshotWithFixtures(reducer, fixtures));
