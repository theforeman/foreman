import { START_INTERVAL, STOP_INTERVAL } from '../IntervalConstants';
import { IntervalMiddleware } from '../IntervalMiddleware';
import {
  key,
  interval,
  args,
  fakeStore,
  fakeStoreWithKey,
} from '../IntervalFixtures';
import {
  registeredIntervalException,
  unregisteredIntervalException,
} from '../IntervalHelpers';

describe('Interval Middleware', () => {
  it('should handle START_INTERVAL action', () => {
    const fakeNext = jest.fn();
    const callback = jest.fn();
    const action = {
      type: START_INTERVAL,
      payload: {
        key,
        callback,
        interval,
        args,
      },
    };

    IntervalMiddleware(fakeStore)(fakeNext)(action);
    expect(callback).toBeCalled();
    expect(fakeNext).toMatchSnapshot();
  });

  it('should handle START_INTERVAL action when key already exists', () => {
    const fakeNext = jest.fn();
    const callback = jest.fn();
    const action = {
      type: START_INTERVAL,
      payload: {
        key,
        callback,
        interval,
        args,
      },
    };
    try {
      IntervalMiddleware(fakeStoreWithKey)(fakeNext)(action);
    } catch (error) {
      expect(error.message).toBe(registeredIntervalException(key).message);
    }
    expect(callback).not.toBeCalled();
    expect(fakeNext).not.toBeCalled();
  });

  it('should handle STOP_INTERVAL action', () => {
    const fakeNext = jest.fn();
    const action = {
      type: STOP_INTERVAL,
      payload: {
        key,
      },
    };

    IntervalMiddleware(fakeStoreWithKey)(fakeNext)(action);
    expect(fakeNext).toMatchSnapshot();
  });

  it('should handle STOP_INTERVAL action when key does not exist', () => {
    const fakeNext = jest.fn();
    const action = {
      type: STOP_INTERVAL,
      payload: {
        key,
      },
    };

    try {
      IntervalMiddleware(fakeStore)(fakeNext)(action);
    } catch (error) {
      expect(error.message).toBe(unregisteredIntervalException(key).message);
    }
    expect(fakeNext).not.toBeCalled();
  });

  it('should pass action to next', () => {
    const fakeNext = jest.fn();
    const callback = jest.fn();
    const action = {
      type: START_INTERVAL,
      payload: {
        key,
        callback,
        interval,
        args,
      },
    };

    IntervalMiddleware(fakeStore)(fakeNext)(action);
    expect(fakeNext).toMatchSnapshot();
  });
});
