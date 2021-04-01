import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_IS_NAV_OPEN,
} from '../LayoutConstants';

import reducer from '../LayoutReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should return the initial state': {},
  'should handle LAYOUT_INITIALIZE': {
    action: {
      type: LAYOUT_INITIALIZE,
      payload: {
        items: 'some-items',
        organization: 'some organization',
        location: 'some location',
      },
    },
  },
  'should handle LAYOUT_SHOW_LOADING': {
    action: {
      type: LAYOUT_SHOW_LOADING,
    },
  },
  'should handle LAYOUT_HIDE_LOADING': {
    action: {
      type: LAYOUT_HIDE_LOADING,
    },
  },
  'should handle LAYOUT_CHANGE_IS_NAV_OPEN': {
    action: {
      type: LAYOUT_CHANGE_IS_NAV_OPEN,
      payload: { isNavOpen: false },
    },
  },
};

describe('Layout reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
