import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import reducer from '../TypeAheadSelectReducer';
import {
  INIT,
  UPDATE_OPTIONS,
  UPDATE_SELECTED,
} from '../TypeAheadSelectConstants';
import { id, options, selected } from '../TypeAheadSelect.fixtures';

const fixtures = {
  'initial state': {},
  'initiates defaults': {
    action: {
      type: INIT,
      payload: {
        id,
        options,
        selected,
      },
    },
  },
  'updates options': {
    action: {
      type: UPDATE_OPTIONS,
      payload: {
        id,
        options,
      },
    },
  },
  'updates selections': {
    action: {
      type: UPDATE_SELECTED,
      payload: {
        id,
        selected,
      },
    },
  },
};

describe('TypeAheadSelectReducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
