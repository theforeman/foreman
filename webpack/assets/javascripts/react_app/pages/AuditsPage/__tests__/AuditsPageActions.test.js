import API from '../../../API';

import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import { fetchAudits } from '../AuditsPageActions';
import {
  getMock,
  responseMock,
  emptyResponseMock,
} from '../AuditsPage.fixtures';

jest.mock('../../../API');

const runFetchAudits = (state, params) => dispatch => {
  const getState = () => ({
    auditsPage: state,
  });
  fetchAudits(params)(dispatch, getState);
};

const runFetchAuditsAPI = (state, resourceMock, serverMock) => {
  API.get.mockImplementation(serverMock);

  return runFetchAudits(state, resourceMock);
};

const fixtures = {
  'should fetch Audits': () =>
    runFetchAuditsAPI(
      { showMessage: false },
      getMock,
      async () => responseMock
    ),

  'should fetch Audits and replace historyState': () =>
    runFetchAuditsAPI(
      { showMessage: false },
      { ...getMock, historyReplace: true },
      async () => responseMock
    ),

  'should fetch Audits without historyPush': () =>
    runFetchAuditsAPI(
      { showMessage: false },
      { ...getMock, historyPush: false },
      async () => responseMock
    ),

  'should fetch empty Audits': () =>
    runFetchAuditsAPI(
      { showMessage: false },
      { ...getMock, searchQuery: 'no-such-audit' },
      async () => emptyResponseMock
    ),

  'should fetch Audits and remove emptyState': () =>
    runFetchAuditsAPI({ showMessage: true }, getMock, async () => responseMock),

  'should fetch Audits and fail': () =>
    runFetchAuditsAPI({ showMessage: true }, getMock, async () => {
      throw new Error('some-error');
    }),
};

describe('AuditsPage actions', () => testActionSnapshotWithFixtures(fixtures));
