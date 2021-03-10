import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_COLLAPSE,
  LAYOUT_EXPAND,
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
        activeMenu: 'some-menu',
        isCollapsed: true,
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
  'should handle LAYOUT_CHANGE_ACTIVE': {
    action: {
      type: LAYOUT_CHANGE_ACTIVE,
      payload: {
        activeMenu: 'Monitor',
      },
    },
  },
  'should handle LAYOUT_COLLAPSE': {
    action: {
      type: LAYOUT_COLLAPSE,
    },
  },
  'should handle LAYOUT_EXPAND': {
    action: {
      type: LAYOUT_EXPAND,
    },
  },
};

describe('Layout reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
