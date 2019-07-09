import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import API from '../../../redux/API/API';
import { loadSetting } from '../SettingsActions';
import { APIMiddleware } from '../../../redux/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

jest.mock('../../../redux/API/API');
const middlewares = [thunk, APIMiddleware];
const mockStore = configureMockStore(middlewares);
const store = mockStore();

const successResponse = {
  data: 'some-data',
};

afterEach(() => {
  store.clearActions();
});

describe('Settings actions', () => {
  it('should load settings and success', async () => {
    API.get.mockImplementation(
      url =>
        new Promise((resolve, reject) => {
          resolve(successResponse);
        })
    );
    await store.dispatch(loadSetting('some-name'));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });

  it('should load settings and fail', async () => {
    API.get.mockImplementation(
      url =>
        new Promise((resolve, reject) => {
          reject(Error('some-error'));
        })
    );
    await store.dispatch(loadSetting('some-name'));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
});
