import { testReducerSnapshotWithFixtures } from '../../common/testHelpers';
import reducer from './ModelsTableReducer';
import { MODELS_TABLE_ACTION_TYPES } from './ModelsTableConstants';

const fixtures = {
  'should return initial state': {},
  'should handle MODELS_TABLE_REQUEST': {
    action: {
      type: MODELS_TABLE_ACTION_TYPES.REQUEST,
    },
  },
  'should handle MODELS_TABLE_SUCCESS': {
    action: {
      type: MODELS_TABLE_ACTION_TYPES.SUCCESS,
      payload: {
        search: 'name=model',
        results: [{ id: 23, name: 'model' }],
        page: 1,
        per_page: 5,
        total: 20,
        sort: { by: 'name', order: 'ASC' },
      },
    },
  },
  'should handle MODELS_TABLE_FAILURE': {
    action: {
      type: MODELS_TABLE_ACTION_TYPES.FAILURE,
      payload: {
        error: new Error('ooops!'),
      },
    },
  },
};

describe('ModelsTable reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
