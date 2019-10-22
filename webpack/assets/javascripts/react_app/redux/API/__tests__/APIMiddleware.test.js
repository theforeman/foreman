import { APIMiddleware, API_OPERATIONS } from '../';
import { get } from '../APIRequest';
import { startPolling } from '../APIActions';
import { registeredPollingException } from '../APIHelpers';

jest.mock('../APIRequest');
jest.mock('../APIActions');

describe('APIMiddleware', () => {
  it('should not call get request', async () => {
    get.mockImplementation(jest.fn());
    APIMiddleware()(jest.fn())({ type: 'TEST' });
    expect(get.mock.calls).toHaveLength(0);
  });

  it('should call get request', async () => {
    get.mockImplementation(jest.fn());
    APIMiddleware()(jest.fn())({ type: API_OPERATIONS.GET });
    expect(get).toBeCalled();
  });

  it('should pass the API action to next', () => {
    const fakeStore = {};
    const fakeNext = jest.fn();

    const action = { type: API_OPERATIONS.GET };
    APIMiddleware(fakeStore)(fakeNext)(action);
    expect(fakeNext).toHaveBeenCalledWith(action);
  });

  it('should pass the polling action to next', async () => {
    const key = 'SOME_KEY';
    const polling = 3000;
    const fakeNext = jest.fn();
    const fakeState = {
      API_operations: {
        polling: {},
      },
    };
    const fakeStore = {
      ...fakeState,
      getState: () => fakeState,
    };
    const action = { type: API_OPERATIONS.GET, key, polling };
    startPolling.mockImplementation(jest.fn());
    APIMiddleware(fakeStore)(fakeNext)(action);
    expect(startPolling).toBeCalled();
    expect(fakeNext).toMatchSnapshot();
  });

  it('should throw error when trying to create polling with existing key', async () => {
    const key = 'SOME_KEY';
    const polling = 3000;
    const fakeNext = jest.fn();
    const fakeState = {
      API_operations: {
        polling: {
          [key]: 1,
        },
      },
    };
    const fakeStore = {
      ...fakeState,
      getState: () => fakeState,
    };
    const action = { type: API_OPERATIONS.GET, key, polling };
    try {
      APIMiddleware(fakeStore)(fakeNext)(action);
    } catch (error) {
      expect(error.message).toBe(registeredPollingException(key).message);
    }
  });
});
