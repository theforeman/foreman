import { API } from '../../../../redux/API';
import { testActionSnapshotWithFixtures } from '../../../../common/testHelpers';
import {
  fetchAudits,
  fetchAndPush,
  initializeAudits,
} from '../AuditsPageActions';
import {
  getMock,
  responseMock,
  emptyResponseMock,
  state as stateMock,
} from '../AuditsPage.fixtures';

jest.mock('../../../../redux/API/API');

const runWithGetState = (state, action, ...params) => async dispatch => {
  const getState = () => ({
    auditsPage: state,
  });
  await action(...params)(dispatch, getState);
};

const runFetchAuditsAPI = (state, resourceMock, serverMock) => {
  API.get.mockImplementation(serverMock);

  return runWithGetState(state, fetchAudits, resourceMock);
};

const fixtures = {
  'should fetch Audits': () =>
    runFetchAuditsAPI(stateMock.auditsPage, getMock, async () => responseMock),

  'should fetch empty Audits': () =>
    runFetchAuditsAPI(
      stateMock.auditsPage,
      { ...getMock, searchQuery: 'no-such-audit' },
      async () => emptyResponseMock
    ),

  'should fetch Audits and remove emptyState': () =>
    runFetchAuditsAPI(stateMock.auditsPage, getMock, async () => responseMock),

  'should fetch Audits and fail': () =>
    runFetchAuditsAPI(stateMock.auditsPage, getMock, async () => {
      const error = new Error('some-error');
      error.response = {
        status: 'some-status',
        statusText: 'some status text',
      };
      throw error;
    }),

  'should fetchAndPush': () =>
    runWithGetState(
      {
        ...stateMock.auditsPage,
        query: { page: 1, perPage: 20, searchQuery: 'search' },
      },
      fetchAndPush,
      getMock
    ),
  'should initializeAudits': () =>
    runWithGetState({ searchQuery: 'search' }, initializeAudits, {}),
};

describe('AuditsPage actions', () => testActionSnapshotWithFixtures(fixtures));
