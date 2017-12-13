import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import immutable from 'seamless-immutable';
import { requestData, onFailureActions, onSuccessActions } from './powerStatus.fixtures';
import * as actions from './index';
import { mockRequest, mockReset } from '../../../../mockRequests';

const mockStore = configureMockStore([thunk]);
const store = mockStore({
  hosts: {
    powerStatus: immutable({}),
  },
});

afterEach(() => {
  store.clearActions();
  mockReset();
});
describe('hosts actions', () => {
  it(
    'creates HOST_POWER_STATUS_REQUEST and fails when host not found',
    () => {
      mockRequest({
        url: requestData.failRequest.url,
        status: 500,
      });
      return store.dispatch(actions.getHostPowerState(requestData.failRequest))
        .then(() =>
          expect(store.getActions()).toEqual(onFailureActions));
    },
  );
  it(
    'creates HOST_POWER_STATUS_REQUEST and responds with success',
    () => {
      mockRequest({
        url: requestData.successRequest.url,
        response: {
          id: 1,
          state: 'na',
          title: 'N/A',
        },
      });
      return store.dispatch(actions.getHostPowerState(requestData.successRequest))
        .then(() =>
          expect(store.getActions()[1]).toEqual(onSuccessActions));
    },
  );
});
