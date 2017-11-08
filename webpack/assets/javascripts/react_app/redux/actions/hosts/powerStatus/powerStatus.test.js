import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import immutable from 'seamless-immutable';

import { requestData, onFailureActions } from './powerStatus.fixtures';

import * as actions from './index';

const mockStore = configureMockStore([thunk]);

describe('hosts actions', () => {
  it('creates HOST_POWER_STATUS_REQUEST and fails when http mocking is not applied', () => {
    const store = mockStore({
      hosts: {
        powerStatus: immutable({}),
      },
    });

    store.dispatch(actions.getHostPowerState(requestData));
    expect(store.getActions()).toEqual(onFailureActions);
  });
});
