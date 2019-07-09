import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import API from '../../../../redux/API/API';
import { getStatisticsMeta } from '../StatisticsPageActions';
import { statisticsProps } from '../StatisticsPage.fixtures';

import { APIMiddleware } from '../../../../redux/API';
import IntegrationTestHelper from '../../../../common/IntegrationTestHelper';

const middlewares = [thunk, APIMiddleware];
const mockStore = configureMockStore(middlewares);
const store = mockStore();

afterEach(() => {
  store.clearActions();
});

jest.mock('../../../../redux/API/API');

describe('StatisticsPage actions', () => {
  it('should fetch statisticsMeta', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve({
            data: statisticsProps.statisticsMeta,
          });
        })
    );
    await store.dispatch(getStatisticsMeta());
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
  it('should fetch statisticsMeta and fail', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(Error('some-error'));
        })
    );
    await store.dispatch(getStatisticsMeta());
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
});
