import { STOP_INTERVAL, START_INTERVAL } from './IntervalConstants';

export const stopInterval = key => ({
  type: STOP_INTERVAL,
  key,
});

export const startIntervalAction = (key, intervalID) => ({
  type: START_INTERVAL,
  key,
  intervalID,
});
