import { API } from '../';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { action, key, actionWithTimestamp } from '../APIFixtures';
import { apiRequest } from '../APIRequest';
import { mockNowDate } from '../../../common/testHelpers';

const data = { results: [1] };
jest.mock('../');

describe('API get', () => {
  const store = {
    dispatch: jest.fn(),
    getState: jest.fn(() => ({ intervals: { [key]: 1 }, API: { [key]: { payload: {} } } })),
  };
  beforeEach(() => {
    store.dispatch = jest.fn();
  });

  it('should dispatch request and success actions on resolve', async () => {
    const apiSuccessResponse = { data };
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve(apiSuccessResponse);
        })
    );
    const modifiedAction = { ...action };
    modifiedAction.payload.handleSuccess = jest.fn();
    apiRequest(modifiedAction, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(modifiedAction.payload.handleSuccess.mock.calls).toMatchSnapshot();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch request and failure actions on reject', async () => {
    const apiError = new Error('bad request');
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(apiError);
        })
    );
    const modifiedAction = { ...action };
    modifiedAction.payload.handleError = jest.fn();
    apiRequest(modifiedAction, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(modifiedAction.payload.handleError.mock.calls).toMatchSnapshot();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch stop interval on API error', async () => {
    const apiError = new Error('bad request');
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(apiError);
        })
    );
    const modifiedAction = { ...action };
    modifiedAction.payload.handleError = jest.fn();
    apiRequest(modifiedAction, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(modifiedAction.payload.handleError.mock.calls).toMatchSnapshot();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch a success toast notification on API resolve', async () => {
    const apiSuccessResponse = { data };
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve(apiSuccessResponse);
        })
    );
    const modifiedAction = { ...action };
    modifiedAction.payload.successToast = jest.fn(
      () => 'Your API request was successful!'
    );
    apiRequest(modifiedAction, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(modifiedAction.payload.successToast).toHaveBeenLastCalledWith(
      apiSuccessResponse
    );
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch an error toast notification on API failure', async () => {
    const apiError = new Error('bad request');
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(apiError);
        })
    );
    const modifiedAction = { ...action };
    modifiedAction.payload.errorToast = jest.fn(
      error =>
        `Oh no! Something went wrong, server returned the error: ${error.message}`
    );
    apiRequest(modifiedAction, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(modifiedAction.payload.errorToast).toHaveBeenLastCalledWith(
      apiError
    );
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should not dispatch when timestamp is valid', async () => {
    const realDateNow = mockNowDate(1530518207007);
    store.getState = jest.fn(() => ({ API: { [key]: { payload: { timestamp: Date.now() - 10000 } } } }))
    const apiSuccessResponse = { data };
    API.get.mockImplementation(
      () =>
        new Promise(resolve => {
          resolve(apiSuccessResponse);
        })
    );
    apiRequest(actionWithTimestamp, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
    realDateNow();
  });

  it('should dispatch when timestamp is outdated', async () => {
    const realDateNow = mockNowDate(1530518207007);
    store.getState = jest.fn(() => ({ API: { [key]: { payload: { timestamp: Date.now() - 15000 } } } }))
    const apiSuccessResponse = { data };
    API.get.mockImplementation(
      () =>
        new Promise(resolve => {
          resolve(apiSuccessResponse);
        })
    );
    apiRequest(actionWithTimestamp, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
    realDateNow();
  });
});
