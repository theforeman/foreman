import { API } from '../';
import { action, key, postActionWithCallback } from '../APIFixtures';
import { apiRequest } from '../APIRequest';

const data = { results: [1] };
jest.mock('../');

const createStore = () => ({
  dispatch: jest.fn(),
  getState: jest.fn(() => ({
    intervals: { [key]: 1 },
    API: {
      INITIAL_RESOURCE: { response: { results: [2] } },
    },
  })),
});

describe('API get', () => {
  let store;
  beforeEach(() => {
    store = createStore();
    jest.clearAllMocks();
  });

  it('should dispatch request and success actions on resolve', async () => {
    const apiSuccessResponse = { data };
    API.get.mockResolvedValue(apiSuccessResponse);

    const modifiedAction = { ...action };
    modifiedAction.payload.handleSuccess = jest.fn();

    await apiRequest(modifiedAction, store);

    expect(store.dispatch).toHaveBeenCalledTimes(2);
    expect(store.dispatch).toHaveBeenNthCalledWith(1, {
      type: 'SOME_KEY_REQUEST',
      key,
      payload: { id: 2, url: 'some/url' },
    });
    expect(store.dispatch).toHaveBeenNthCalledWith(2, {
      type: 'SOME_KEY_SUCCESS',
      key,
      payload: { id: 2, url: 'some/url' },
      response: data,
    });
    expect(modifiedAction.payload.handleSuccess).toHaveBeenCalledWith(
      apiSuccessResponse,
      expect.any(Function)
    );
  });

  it('should dispatch request and failure actions on reject', async () => {
    const apiError = new Error('bad request');
    API.get.mockRejectedValue(apiError);

    const modifiedAction = { ...action };
    modifiedAction.payload.handleError = jest.fn();

    await apiRequest(modifiedAction, store);

    expect(store.dispatch).toHaveBeenCalledTimes(2);
    expect(store.dispatch).toHaveBeenNthCalledWith(1, {
      type: 'SOME_KEY_REQUEST',
      key,
      payload: { id: 2, url: 'some/url' },
    });
    expect(store.dispatch).toHaveBeenNthCalledWith(2, {
      type: 'SOME_KEY_FAILURE',
      key,
      payload: { id: 2, url: 'some/url' },
      response: apiError,
    });
    expect(modifiedAction.payload.handleError).toHaveBeenCalledWith(
      apiError,
      expect.any(Function)
    );
  });

  it('should dispatch a success toast notification on API resolve', async () => {
    const apiSuccessResponse = { data };
    API.get.mockResolvedValue(apiSuccessResponse);

    const modifiedAction = { ...action };
    modifiedAction.payload.successToast = jest.fn(
      () => 'Your API request was successful!'
    );

    await apiRequest(modifiedAction, store);

    expect(modifiedAction.payload.successToast).toHaveBeenCalledWith(
      apiSuccessResponse
    );
    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenNthCalledWith(3, {
      type: 'toasts/addToast',
      payload: {
        key: 'SOME_KEY_SUCCESS',
        toast: {
          key: 'SOME_KEY_SUCCESS',
          message: 'Your API request was successful!',
          type: 'success',
        },
      },
    });
  });

  it('should dispatch an error toast notification on API failure', async () => {
    const apiError = new Error('bad request');
    API.get.mockRejectedValue(apiError);

    const modifiedAction = { ...action };
    modifiedAction.payload.errorToast = jest.fn(
      error =>
        `Oh no! Something went wrong, server returned the error: ${error.message}`
    );

    await apiRequest(modifiedAction, store);

    expect(modifiedAction.payload.errorToast).toHaveBeenCalledWith(apiError);
    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenNthCalledWith(3, {
      type: 'toasts/addToast',
      payload: {
        key: 'SOME_KEY_FAILURE',
        toast: {
          key: 'SOME_KEY_FAILURE',
          message:
            'Oh no! Something went wrong, server returned the error: bad request',
          type: 'danger',
        },
      },
    });
  });

  it('should dispatch an update if an updateData callback exists', async () => {
    const apiSuccessResponse = { data };
    API.post.mockResolvedValue(apiSuccessResponse);

    await apiRequest(postActionWithCallback, store);

    expect(store.dispatch).toHaveBeenCalledTimes(3);
    expect(store.dispatch).toHaveBeenNthCalledWith(1, {
      type: 'SOME_KEY_REQUEST',
      key: 'INITIAL_RESOURCE',
      payload: { id: 2, url: 'some/url' },
    });
    expect(store.dispatch).toHaveBeenNthCalledWith(2, {
      type: 'SOME_KEY_SUCCESS',
      key: 'INITIAL_RESOURCE',
      payload: { id: 2, url: 'some/url' },
      response: data,
    });
    expect(store.dispatch).toHaveBeenNthCalledWith(3, {
      type: 'SOME_KEY_UPDATE',
      key: 'INITIAL_RESOURCE',
      payload: { results: [3] },
    });
  });
});
