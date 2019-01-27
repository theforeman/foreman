import {
  AUDITS_PAGE_SHOW_MESSAGE,
  AUDITS_PAGE_HIDE_MESSAGE,
  AUDITS_PAGE_FETCH,
} from '../AuditsPageConstants';

import reducer from '../AuditsPageReducer';

import { testReducerSnapshotWithFixtures } from '../../../common/testHelpers';
import { AuditsProps } from '../../../components/AuditsList/__tests__/AuditsList.fixtures';

const fixtures = {
  'should return the initial state': {},
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
        page: 1,
        perPage: 20,
        itemCount: 21,
        searchQuery: 'search',
      },
    },
  },
};

describe('AuditsPage reducer', () =>
  testReducerSnapshotWithFixtures(reducer, fixtures));
