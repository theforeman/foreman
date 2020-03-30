import { DebounceMiddleware } from '../DebounceMiddleware';
import { clearDebounce } from '../DebounceActions';
import {
  key,
  initialState,
  stateWithKey,
  actionWithDebounce,
} from '../DebounceFixtures';

describe('Debounce Middleware', () => {
  const getFakeStore = () => ({
    getState: () => ({
      debounce: initialState,
    }),
    dispatch: jest.fn(),
  });

  const getFakeStoreWithKey = () => ({
    getState: () => ({
      debounce: stateWithKey,
    }),
    dispatch: jest.fn(),
  });

  it('should handle an action with "debounce" key', () => {
    const fakeStore = getFakeStore();
    const fakeNext = jest.fn();

    DebounceMiddleware(fakeStore)(fakeNext)(actionWithDebounce);
    expect(fakeStore.dispatch).toMatchSnapshot();
    expect(fakeNext).not.toBeCalled();
  });

  it('should stop incoming action due to active debounce', () => {
    const fakeStore = getFakeStoreWithKey();
    const fakeNext = jest.fn();

    DebounceMiddleware(fakeStore)(fakeNext)(actionWithDebounce);
    expect(fakeStore.dispatch).toMatchSnapshot();
  });

  it('should handle DEBOUNCE_CLEAR action', () => {
    const fakeStore = getFakeStoreWithKey();
    const fakeNext = jest.fn();
    const stopAction = clearDebounce(key);

    DebounceMiddleware(fakeStore)(fakeNext)(stopAction);
    expect(fakeNext).toMatchSnapshot();
  });
});
