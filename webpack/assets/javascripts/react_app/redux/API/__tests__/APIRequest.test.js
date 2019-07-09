import { get } from '../APIRequest';
import API from '../API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

const data = { results: [1] };
const payload = { name: 'test', id: 'myid' };
jest.mock('../API');

describe('API get', () => {
  const store = { dispatch: jest.fn() };
  const url = 'test/subtest';
  const actionTypes = {
    REQUEST: 'TEST_REQUEST',
    SUCCESS: 'TEST_SUCCESS',
    FAILURE: 'TEST_FAILURE',
  };
  const formatDefault = data1 => data1;
  let onSuccess;
  let onFailure;
  beforeEach(() => {
    store.dispatch = jest.fn();
    onSuccess = jest.fn();
    onFailure = jest.fn();
  });

  it('should dispatch request and success actions on resolve', async () => {
    API.get.mockImplementationOnce(
      () =>
        new Promise((resolve, reject) => {
          resolve({ data });
        })
    );
    get(
      payload,
      url,
      store,
      actionTypes,
      formatDefault,
      formatDefault,
      onSuccess,
      onFailure
    );
    await IntegrationTestHelper.flushAllPromises();
    expect(onSuccess).toBeCalled();
    expect(onFailure.mock.calls).toHaveLength(0);
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch request and failure actions on reject', async () => {
    API.get.mockImplementationOnce(
      () =>
        new Promise((resolve, reject) => {
          reject(Error('bad request'));
        })
    );
    get(
      payload,
      url,
      store,
      actionTypes,
      formatDefault,
      formatDefault,
      onSuccess,
      onFailure
    );
    await IntegrationTestHelper.flushAllPromises();
    expect(onFailure).toBeCalled();
    expect(onSuccess.mock.calls).toHaveLength(0);
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should format success response', async () => {
    API.get.mockImplementationOnce(
      () =>
        new Promise((resolve, reject) => {
          resolve({ data });
        })
    );

    const successFormat = success => ({
      success: `Formatted success ${success.results}`,
    });
    get(
      payload,
      url,
      store,
      actionTypes,
      formatDefault,
      successFormat,
      onSuccess,
      onFailure
    );
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should format fail response', async () => {
    const errorFormat = error => [`Formatted error ${error.error}`];
    API.get.mockImplementationOnce(
      () =>
        new Promise((resolve, reject) => {
          reject(Error('bad request'));
        })
    );
    get(
      payload,
      url,
      store,
      actionTypes,
      errorFormat,
      formatDefault,
      onSuccess,
      onFailure
    );
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });
});
