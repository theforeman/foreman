import { IntervalMiddleware } from '../IntervalMiddleware';
import {
  key,
  initialState,
  stateWithKey,
  actionWithInterval,
} from '../IntervalFixtures';
import { registeredIntervalException } from '../IntervalHelpers';
import { stopInterval } from '../IntervalActions';

jest.useFakeTimers();

describe('Interval Middleware', () => {
  const getFakeStore = () => ({
    getState: () => ({
      intervals: initialState,
    }),
    dispatch: jest.fn(),
  });

  const getFakeStoreWithKey = () => ({
    getState: () => ({
      intervals: stateWithKey,
    }),
    dispatch: jest.fn(),
  });

  it('should handle an action with "interval" key', () => {
    const fakeStore = getFakeStore();
    const fakeNext = jest.fn();

    IntervalMiddleware(fakeStore)(fakeNext)(actionWithInterval);
    expect(fakeStore.dispatch).toMatchSnapshot();
    expect(fakeNext).not.toBeCalled();
  });

  it('should handle START_INTERVAL action when key already exists', () => {
    const fakeStore = getFakeStoreWithKey();
    const fakeNext = jest.fn();

    try {
      IntervalMiddleware(fakeStore)(fakeNext)(actionWithInterval);
    } catch (error) {
      expect(error.message).toBe(registeredIntervalException(key).message);
    }
    expect(fakeStore.dispatch).not.toBeCalled();
    expect(fakeNext).not.toBeCalled();
  });

  it('should handle STOP_INTERVAL action', () => {
    const fakeStore = getFakeStoreWithKey();
    const fakeNext = jest.fn();
    const stopAction = stopInterval(key);

    IntervalMiddleware(fakeStore)(fakeNext)(stopAction);
    expect(clearInterval).toHaveBeenCalled();
    expect(fakeNext).toMatchSnapshot();
  });

  it('should pass action to next', () => {
    const fakeStore = getFakeStoreWithKey();
    const fakeNext = jest.fn();
    const action = { type: 'SOME_TYPE' };

    IntervalMiddleware(fakeStore)(fakeNext)(action);
    expect(fakeNext).toMatchSnapshot();
  });
});
