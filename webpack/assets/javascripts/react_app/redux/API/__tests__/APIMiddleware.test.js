import { APIMiddleware, API_OPERATIONS } from '../';
import { get } from '../APIRequest';

jest.mock('../APIRequest');

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
});
