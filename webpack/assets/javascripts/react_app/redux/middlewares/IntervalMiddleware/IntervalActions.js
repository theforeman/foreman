import { STOP_INTERVAL, START_INTERVAL } from './IntervalConstants';

export const stopInterval = key => ({
  type: STOP_INTERVAL,
  payload: {
    key,
  },
});

export const startInterval = (key, method, interval, ...args) => ({
  type: START_INTERVAL,
  payload: {
    key,
    method,
    interval,
    args: [...args],
  },
});
