import { APIMiddleware, API_OPERATIONS } from '../';
import { apiRequest } from '../APIRequest';

jest.mock('../APIRequest');

describe('APIMiddleware', () => {
  it('should not call apiRequest if action type is irrelevant', async () => {
    apiRequest.mockImplementation(jest.fn());
    APIMiddleware()(jest.fn())({ type: 'TEST' });
    expect(apiRequest.mock.calls).toHaveLength(0);
  });

  it('should call apiRequest when action type is relevant', async () => {
    apiRequest.mockImplementation(jest.fn());
    APIMiddleware()(jest.fn())({ type: API_OPERATIONS.GET, payload: { key: 'TEST_KEY' } });
    expect(apiRequest).toBeCalled();
  });

  it('should pass the API action to next', () => {
    const fakeStore = {};
    const fakeNext = jest.fn();

    const action = { type: API_OPERATIONS.GET, payload: { key: 'TEST_KEY' } };
    APIMiddleware(fakeStore)(fakeNext)(action);
    expect(fakeNext).toHaveBeenCalledWith(action);
  });
});
