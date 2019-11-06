import { STOP_INTERVAL, START_INTERVAL } from './IntervalConstants';

export const stopInterval = key => ({
  type: STOP_INTERVAL,
  payload: {
    key,
  },
});

export const startInterval = (key, callback, interval, ...intervalArgs) => ({
  type: START_INTERVAL,
  payload: {
    key,
    callback,
    interval,
    args: [...intervalArgs],
  },
});
