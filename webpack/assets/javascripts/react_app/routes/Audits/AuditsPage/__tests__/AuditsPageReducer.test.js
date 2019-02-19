import {
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
  AUDITS_PAGE_SHOW_LOADING,
  AUDITS_PAGE_HIDE_LOADING,
  AUDITS_PAGE_CHANGE_PARAMS,
  AUDITS_PAGE_FETCH,
  AUDITS_PAGE_NEXT_PENDING,
  AUDITS_PAGE_NEXT_RESOLVED,
  AUDITS_PAGE_PREV_PENDING,
  AUDITS_PAGE_PREV_RESOLVED,
  AUDITS_PAGE_CLEAR_CACHE,
} from '../AuditsPageConstants';

import reducer from '../AuditsPageReducer';

import { testReducerSnapshotWithFixtures } from '../../../../common/testHelpers';
import { AuditsProps } from '../../../../components/AuditsList/__tests__/AuditsList.fixtures';

const fixtures = {
  'should return the initial state': {},
  'should handle AUDITS_PAGE_NEXT_PENDING': {
    action: {
      type: AUDITS_PAGE_NEXT_PENDING,
    },
  },
  'should handle AUDITS_PAGE_NEXT_RESOLVED': {
    action: {
      type: AUDITS_PAGE_NEXT_RESOLVED,
    },
  },
  'should handle AUDITS_PAGE_PREV_PENDING': {
    action: {
      type: AUDITS_PAGE_PREV_PENDING,
    },
  },
  'should handle AUDITS_PAGE_PREV_RESOLVED': {
    action: {
      type: AUDITS_PAGE_PREV_RESOLVED,
    },
  },
  'should handle AUDITS_PAGE_CLEAR_CACHE': {
    action: {
      type: AUDITS_PAGE_CLEAR_CACHE,
    },
  },
  'should handle AUDITS_PAGE_SHOW_LOADING': {
    action: {
      type: AUDITS_PAGE_SHOW_LOADING,
    },
  },
  'should handle AUDITS_PAGE_HIDE_LOADING': {
    action: {
      type: AUDITS_PAGE_HIDE_LOADING,
    },
  },
  'should handle AUDITS_PAGE_HIDE_MESSAGE': {
    action: {
      type: AUDITS_PAGE_HIDE_MESSAGE,
    },
  },
  'should handle AUDITS_PAGE_SHOW_MESSAGE': {
    action: {
      type: AUDITS_PAGE_SHOW_MESSAGE,
      payload: {
        showMessage: true,
        message: {
          text: __('No Audits found, please search again.'),
          type: 'empty',
        },
      },
    },
  },
  'should handle AUDITS_PAGE_FETCH': {
    action: {
      type: AUDITS_PAGE_FETCH,
      payload: {
        audits: AuditsProps.audits,
        itemCount: 21,
      },
    },
  },
  'should handle AUDITS_PAGE_CHANGE_PARAMS': {
    action: {
      type: AUDITS_PAGE_CHANGE_PARAMS,
      payload: {
        page: 2,
        perPage: 21,
        searchQuery: 'search',
      },
    },
  },
};

describe('AuditsPage reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
