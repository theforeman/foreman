import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import immutable from 'seamless-immutable';
import { mockRequest, mockReset } from '../../../mockRequests';
import { failedRequestData, successRequestData, onFailureActions, onSuccessActions } from './statistics.fixtures';

import * as actions from './index';

const mockStore = configureMockStore([thunk]);
const store = mockStore({ statistics: immutable({}) });

afterEach(() => {
  store.clearActions();
  mockReset();
});

describe('statistics actions', () => {
  it(
    'creates STATISTICS_DATA_REQUEST and then fails with 422',
    () => {
      mockRequest({
        url: '/statistics/architecture',
        status: 422,
      });
      mockRequest({
        url: '/statistics/operatingsystem',
        status: 422,
      });
      return store.dispatch(actions.getStatisticsData(failedRequestData))
        .then(() => expect(store.getActions()).toEqual(onFailureActions));
    },
  );
  it(
    'creates STATISTICS_DATA_REQUEST and ends with success',
    () => {
      mockRequest({
        url: '/statistics/operatingsystem',
        response: {
          id: 'operatingsystem',
          data: [['centOS 7.1', 6]],
        },
      });
      mockRequest({
        url: '/statistics/architecture',
        response: {
          id: 'architecture',
          data: [['x86_64', 6]],
        },
      });
      return store.dispatch(actions.getStatisticsData(successRequestData))
        .then(() => expect(store.getActions()).toEqual(onSuccessActions));
    },
  );
});
