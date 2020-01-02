import { get } from '../APIRequest';
import { API } from '../';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';
import { action } from '../APIFixtures';

const data = { results: [1] };
jest.mock('../');

describe('API get', () => {
  const store = { dispatch: jest.fn() };
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
    get(action.payload, store);
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
    get(action.payload, store);
    await IntegrationTestHelper.flushAllPromises();
    expect(store.dispatch.mock.calls).toMatchSnapshot();
  });
});
