import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import immutable from 'seamless-immutable';
import {
  failedRequestData,
  successRequestData,
  onFailureActions,
  onSuccessActions,
} from './statistics.fixtures';

import API from '../../API/API';
import { APIMiddleware } from '../../API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import * as actions from './index';

const mockStore = configureMockStore([thunk, APIMiddleware]);
const store = mockStore({ statistics: immutable({}) });

jest.mock('../../API/API');
afterEach(() => {
  store.clearActions();
});

describe('statistics actions', () => {
  it('creates STATISTICS_DATA_REQUEST and then fails with 422', async () => {
    API.get.mockImplementation(
      url =>
        new Promise((resolve, reject) => {
          reject(Error('Request failed with status code 422'));
        })
    );

    store.dispatch(actions.getStatisticsData(failedRequestData));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toEqual(onFailureActions);
  });
  it('creates STATISTICS_DATA_REQUEST and ends with success', async () => {
    API.get
      .mockImplementationOnce(
        url =>
          new Promise((resolve, reject) => {
            resolve({
              data: {
                id: 'operatingsystem',
                data: [['centOS 7.1', 6]],
              },
            });
          })
      )
      .mockImplementationOnce(
        url =>
          new Promise((resolve, reject) => {
            resolve({
              data: {
                id: 'architecture',
                data: [['x86_64', 6]],
              },
            });
          })
      );

    store.dispatch(actions.getStatisticsData(successRequestData));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toEqual(onSuccessActions);
  });
});
