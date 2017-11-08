import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import immutable from 'seamless-immutable';

import { requestData, onFailureActions } from './statistics.fixtures';

import * as actions from './index';

const mockStore = configureMockStore([thunk]);

describe('statistics actions', () => {
  it(
    'creates STATISTICS_DATA_REQUEST and fails when nock is not applied',
    () => {
      const store = mockStore({ statistics: immutable({}) });

      store.dispatch(actions.getStatisticsData(requestData));
      expect(store.getActions()).toEqual(onFailureActions);
    },
  );
});
