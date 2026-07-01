import { API } from '../../../../redux/API';
import history from '../../../../history';
import { getParams, stringifyParams } from '../../../../common/urlHelpers';
import {
  AUDITS_PAGE_CLEAR_ERROR,
  AUDITS_PAGE_DATA_FAILED,
  AUDITS_PAGE_DATA_RESOLVED,
  AUDITS_PAGE_HIDE_LOADING,
  AUDITS_PAGE_SHOW_LOADING,
  AUDITS_PAGE_UPDATE_QUERY,
  AUDITS_PATH,
} from '../../constants';
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
jest.mock('../../../../history', () => ({
  __esModule: true,
  default: {
    push: jest.fn(),
    replace: jest.fn(),
    action: 'PUSH',
  },
}));
jest.mock('../../../../common/urlHelpers', () => ({
  ...jest.requireActual('../../../../common/urlHelpers'),
  getParams: jest.fn(),
}));

const createDispatch = getState => {
  const pendingPromises = [];

  const dispatch = jest.fn(action => {
    if (typeof action === 'function') {
      const result = action(dispatch, getState);

      if (result?.then) {
        pendingPromises.push(result);
      }

      return result;
    }

    return action;
  });

  dispatch.flush = () => Promise.all(pendingPromises);

  return dispatch;
};

const getDispatchedActions = dispatch =>
  dispatch.mock.calls
    .filter(([action]) => typeof action !== 'function')
    .map(([action]) => action);

const createThunkTestHarness = auditsPageState => {
  const getState = () => ({ auditsPage: auditsPageState });
  const dispatch = createDispatch(getState);

  return {
    dispatch,
    getState,
    getActions: () => getDispatchedActions(dispatch),
    runThunk: async thunk => {
      await thunk(dispatch, getState);
    },
    runAndFlush: async actionCreator => {
      actionCreator(dispatch, getState);
      await dispatch.flush();
    },
  };
};

const showLoadingAction = () => ({ type: AUDITS_PAGE_SHOW_LOADING });
const clearErrorAction = () => ({ type: AUDITS_PAGE_CLEAR_ERROR });
const hideLoadingAction = () => ({ type: AUDITS_PAGE_HIDE_LOADING });

const updateQueryAction = (query, itemCount) => ({
  type: AUDITS_PAGE_UPDATE_QUERY,
  payload: {
    page: query.page,
    perPage: query.perPage,
    searchQuery: query.searchQuery,
    itemCount,
  },
});

const dataResolvedAction = (audits, hasData) => ({
  type: AUDITS_PAGE_DATA_RESOLVED,
  payload: { audits, hasData },
});

const dataFailedAction = (text = 'some-status some status text') => ({
  type: AUDITS_PAGE_DATA_FAILED,
  payload: {
    message: { type: 'error', text },
  },
});

const buildFetchSuccessActions = (query, response, { prefix = [] } = {}) => {
  const { audits, itemCount } = response.data;

  return [
    showLoadingAction(),
    ...prefix,
    updateQueryAction(query, itemCount),
    dataResolvedAction(audits, itemCount > 0),
  ];
};

const buildFetchFailureActions = ({ prefix = [] } = {}) => [
  showLoadingAction(),
  ...prefix,
  dataFailedAction(),
];

const runFetchAudits = async (state, query, apiMock) => {
  API.get.mockImplementation(apiMock);
  const harness = createThunkTestHarness(state);

  await harness.runThunk(fetchAudits(query));

  return { dispatch: harness.dispatch, actions: harness.getActions() };
};

const apiError = () => {
  const error = new Error('some-error');
  error.response = {
    status: 'some-status',
    statusText: 'some status text',
  };

  throw error;
};

const loadingState = {
  ...stateMock.auditsPage,
  data: {
    ...stateMock.auditsPage.data,
    isLoading: true,
  },
};

describe('AuditsPage actions', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    history.action = 'PUSH';
    getParams.mockReturnValue({
      page: 1,
      perPage: 20,
      searchQuery: 'search',
    });
  });

  it('should fetch Audits', async () => {
    const { actions } = await runFetchAudits(
      stateMock.auditsPage,
      getMock,
      async () => responseMock
    );

    expect(API.get).toHaveBeenCalledWith(
      AUDITS_PATH,
      {},
      {
        page: getMock.page,
        per_page: getMock.perPage,
        search: getMock.searchQuery,
      }
    );
    expect(actions).toEqual(buildFetchSuccessActions(getMock, responseMock));
  });

  it('should fetch empty Audits', async () => {
    const query = { ...getMock, searchQuery: 'no-such-audit' };
    const { actions } = await runFetchAudits(
      stateMock.auditsPage,
      query,
      async () => emptyResponseMock
    );

    expect(API.get).toHaveBeenCalledWith(
      AUDITS_PATH,
      {},
      {
        page: query.page,
        per_page: query.perPage,
        search: query.searchQuery,
      }
    );
    expect(actions).toEqual(buildFetchSuccessActions(query, emptyResponseMock));
  });

  it('should fetch Audits and remove emptyState', async () => {
    const stateWithError = {
      ...stateMock.auditsPage,
      data: {
        ...stateMock.auditsPage.data,
        hasError: true,
      },
    };
    const { actions } = await runFetchAudits(
      stateWithError,
      getMock,
      async () => responseMock
    );

    expect(actions).toEqual(
      buildFetchSuccessActions(getMock, responseMock, {
        prefix: [clearErrorAction()],
      })
    );
  });

  it('should hide loading after successful fetch when page was loading', async () => {
    const { actions } = await runFetchAudits(
      loadingState,
      getMock,
      async () => responseMock
    );

    expect(actions).toEqual(
      buildFetchSuccessActions(getMock, responseMock, {
        prefix: [hideLoadingAction()],
      })
    );
  });

  it('should hide loading after failed fetch when page was loading', async () => {
    const { actions } = await runFetchAudits(
      loadingState,
      getMock,
      async () => apiError()
    );

    expect(actions).toEqual(
      buildFetchFailureActions({ prefix: [hideLoadingAction()] })
    );
  });

  it('should clear error and fail when refetching after error', async () => {
    const stateWithError = {
      ...stateMock.auditsPage,
      data: {
        ...stateMock.auditsPage.data,
        hasError: true,
      },
    };
    const { actions } = await runFetchAudits(
      stateWithError,
      getMock,
      async () => apiError()
    );

    expect(actions).toEqual(
      buildFetchFailureActions({ prefix: [clearErrorAction()] })
    );
  });

  it('should fetch Audits and fail', async () => {
    const { actions } = await runFetchAudits(
      stateMock.auditsPage,
      getMock,
      async () => apiError()
    );

    expect(actions).toEqual(buildFetchFailureActions());
  });

  it('should fetchAndPush using query defaults from state', async () => {
    API.get.mockImplementation(async () => responseMock);
    const auditsPageState = {
      ...stateMock.auditsPage,
      query: { page: 3, perPage: 50, searchQuery: 'from-state', itemCount: 0 },
    };
    const expectedQuery = {
      page: 3,
      perPage: 50,
      searchQuery: 'from-state',
    };
    const harness = createThunkTestHarness(auditsPageState);

    await harness.runAndFlush(fetchAndPush({}));

    expect(history.push).toHaveBeenCalledWith({
      pathname: AUDITS_PATH,
      search: stringifyParams(expectedQuery),
    });
    expect(API.get).toHaveBeenCalledWith(
      AUDITS_PATH,
      {},
      {
        page: expectedQuery.page,
        per_page: expectedQuery.perPage,
        search: expectedQuery.searchQuery,
      }
    );
  });

  it('should fetchAndPush', async () => {
    API.get.mockImplementation(async () => responseMock);
    const auditsPageState = {
      ...stateMock.auditsPage,
      query: { page: 1, perPage: 20, searchQuery: 'search' },
    };
    const expectedQuery = {
      page: getMock.page,
      perPage: getMock.perPage,
      searchQuery: getMock.searchQuery,
    };
    const harness = createThunkTestHarness(auditsPageState);

    await harness.runAndFlush(fetchAndPush(getMock));

    expect(history.push).toHaveBeenCalledWith({
      pathname: AUDITS_PATH,
      search: stringifyParams(expectedQuery),
    });
    expect(harness.getActions()).toEqual(
      buildFetchSuccessActions(expectedQuery, responseMock)
    );
  });

  it('should initializeAudits without replacing history on POP', async () => {
    API.get.mockImplementation(async () => responseMock);
    history.action = 'POP';
    const params = {
      page: 1,
      perPage: 20,
      searchQuery: 'search',
    };
    getParams.mockReturnValue(params);
    const harness = createThunkTestHarness(stateMock.auditsPage);

    await harness.runAndFlush(initializeAudits());

    expect(getParams).toHaveBeenCalled();
    expect(history.replace).not.toHaveBeenCalled();
  });

  it('should initializeAudits', async () => {
    API.get.mockImplementation(async () => responseMock);
    const params = {
      page: 1,
      perPage: 20,
      searchQuery: 'search',
    };
    getParams.mockReturnValue(params);
    const harness = createThunkTestHarness(stateMock.auditsPage);

    await harness.runAndFlush(initializeAudits());

    expect(getParams).toHaveBeenCalled();
    expect(history.replace).toHaveBeenCalledWith({
      pathname: AUDITS_PATH,
      search: stringifyParams(params),
    });
    expect(harness.getActions()).toEqual(
      buildFetchSuccessActions(params, responseMock)
    );
  });
});
