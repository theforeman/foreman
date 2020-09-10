import {
  DIFF_MODAL_TOGGLE,
  DIFF_MODAL_CREATE,
  DIFF_MODAL_VIEWTYPE,
} from '../DiffModalConstants';

import reducer from '../DiffModalReducer';

import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import { diffModalMock } from '../DiffModal.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should handle DIFF_MODAL_TOGGLE': {
    action: {
      type: DIFF_MODAL_TOGGLE,
    },
  },
  'should handle DIFF_MODAL_CREATE': {
    action: {
      type: DIFF_MODAL_CREATE,
      payload: {
        diff: diffModalMock.diff,
        title: diffModalMock.title,
        isOpen: true,
      },
    },
  },
  'should handle DIFF_MODAL_VIEWTYPE': {
    action: {
      type: DIFF_MODAL_VIEWTYPE,
      payload: {
        diffViewType: 'unified',
      },
    },
  },
};

describe('DiffModal reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
