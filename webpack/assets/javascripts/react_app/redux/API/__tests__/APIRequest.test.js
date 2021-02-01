import { API } from '../';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { action, key, postActionWithCallback } from '../APIFixtures';
import { apiRequest } from '../APIRequest';

const data = { results: [1] };
jest.mock('../');

describe('API get', () => {
  const store = {
    dispatch: jest.fn(),
    getState: jest.fn(() => ({
      intervals: { [key]: 1 },
      API: {
        INITIAL_RESOURCE: { response: { results: [2] } },
      },
    })),
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

  it('should dispatch an update if an updateData callback exists', async () => {
    const apiSuccessResponse = { data };
    API.post.mockImplementation(
      () =>
        new Promise(resolve => {
          resolve(apiSuccessResponse);
        })
    );
    apiRequest(postActionWithCallback, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });
});
