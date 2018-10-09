import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
} from '../BreadcrumbBarConstants';
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
  'should handle BREADCRUMB_BAR_RESOURCES_REQUEST': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: {
        resourceUrl: resource.resourceUrl,
        options: {},
      },
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_REQUEST with search query': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: {
        resourceUrl: resource.resourceUrl,
        options: { searchQuery: 'some search' },
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
        resourceUrl: resource.resourceUrl,
      },
    },
  },
  'should handle BREADCRUMB_BAR_RESOURCES_FAILURE': {
    action: {
      type: BREADCRUMB_BAR_RESOURCES_FAILURE,
      payload: {
        error: new Error('some error'),
        resourceUrl: resource.resourceUrl,
      },
    },
  },
};

describe('BreadcrumbBar reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
