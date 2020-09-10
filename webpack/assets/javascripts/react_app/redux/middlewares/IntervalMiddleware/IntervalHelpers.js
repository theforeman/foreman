import { DEFAULT_INTERVAL } from './IntervalConstants';

export const registeredIntervalException = key =>
  new Error(`There is already an interval running and registered for: ${key}.`);

export const withInterval = (action, interval = getDefaultInterval()) => ({
  ...action,
  interval,
});

export const getDefaultInterval = () =>
  process.env.DEFAULT_INTERVAL || DEFAULT_INTERVAL;
