import {
  registeredIntervalException,
  withInterval,
  getDefaultInterval,
} from '../IntervalHelpers';
import { key, action, interval, actionWithInterval } from '../IntervalFixtures';
import { DEFAULT_INTERVAL } from '../IntervalConstants';

describe('Interval Helpers', () => {
  it('return registeredIntervalException error', () => {
    expect(registeredIntervalException(key)).toMatchSnapshot();
  });

  it('return withInterval modified action', () => {
    expect(withInterval(action, interval)).toEqual(actionWithInterval);
  });

  it('return withInterval modified action using default interval', () => {
    expect(withInterval(action)).toEqual({
      ...action,
      interval: DEFAULT_INTERVAL,
    });
  });

  it('return DEFAULT_INTERVAL', () => {
    expect(getDefaultInterval()).toEqual(DEFAULT_INTERVAL);
  });
});
