import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_UPDATE_ITEMS,
  LAYOUT_CHANGE_ORG,
  LAYOUT_CHANGE_LOCATION,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_COLLAPSE,
  LAYOUT_EXPAND,
} from '../LayoutConstants';

import reducer from '../LayoutReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import { layoutMock } from '../Layout.fixtures';

const fixtures = {
  'should return the initial state': {},
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
  'should handle LAYOUT_UPDATE_ITEMS': {
    action: {
      type: LAYOUT_UPDATE_ITEMS,
      payload: {
        items: layoutMock.items,
      },
    },
  },
  'should handle LAYOUT_CHANGE_ORG': {
    action: {
      type: LAYOUT_CHANGE_ORG,
      payload: {
        org: 'org1',
      },
    },
  },
  'should handle LAYOUT_CHANGE_LOCATION': {
    action: {
      type: LAYOUT_CHANGE_LOCATION,
      payload: {
        location: 'yaml',
      },
    },
  },
};

describe('Layout reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
