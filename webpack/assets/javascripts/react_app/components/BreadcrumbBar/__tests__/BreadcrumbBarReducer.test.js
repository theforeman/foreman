import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
  BREADCRUMB_BAR_RESOURCES,
} from '../BreadcrumbBarConstants';
import { API_OPERATIONS } from '../../../redux/API';

import reducer from '../BreadcrumbBarReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import { resource, resourceList } from '../BreadcrumbBar.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should handle BREADCRUMB_BAR_TOGGLE_SWITCHER': {
    action: {
      type: BREADCRUMB_BAR_TOGGLE_SWITCHER,
    },
  },
  'should handle BREADCRUMB_BAR_CLOSE_SWITCHER': {
    action: {
      type: BREADCRUMB_BAR_CLOSE_SWITCHER,
    },
  },
  'should handle API_GET BREADCRUMB_BAR_RESOURCES': {
    action: {
      type: API_OPERATIONS.GET,
      key: BREADCRUMB_BAR_RESOURCES,
      url: resource.resourceUrl,
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_REQUEST': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: {
        options: {},
      },
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_REQUEST with search query': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: {
        searchQuery: 'some search',
      },
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_SUCCESS': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_SUCCESS,
      payload: {
        items: [...resourceList],
        page: 1,
        pages: 2,
      },
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_FAILURE': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_FAILURE,
      payload: {
        error: new Error('some error'),
      },
    },
  },
};

describe('BreadcrumbBar reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
