import { get } from '../APIRequest';
import { API } from '../';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

const data = { results: [1] };
const payload = { name: 'test', id: 'myid' };
jest.mock('../');

describe('API get', () => {
  const store = { dispatch: jest.fn() };
  const url = 'test/subtest';
  const actionTypes = {
    REQUEST: 'TEST_REQUEST',
    SUCCESS: 'TEST_SUCCESS',
    FAILURE: 'TEST_FAILURE',
  };
  beforeEach(() => {
    store.dispatch = jest.fn();
  });

  it('should dispatch request and success actions on resolve', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve({ data });
        })
    );
    get(payload, url, store, actionTypes);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });

  it('should dispatch request and failure actions on reject', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(Error('bad request'));
        })
    );
    get(payload, url, store, actionTypes);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });
});
