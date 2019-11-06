/* eslint-disable no-case-declarations */
import {
  START_INTERVAL,
  STOP_INTERVAL,
  DEFAULT_INTERVAL,
} from './IntervalConstants';
import { selectIsIntervalExists } from './IntervalSelectors';
import { amendActionsPayload } from '../common/helpers';
import {
  registeredIntervalException,
  unregisteredIntervalException,
} from './IntervalHelpers';

export const IntervalMiddleware = store => next => action => {
  const { type, payload: { key, callback, interval, args = [] } = {} } = action;
  const state = store.getState();

  switch (type) {
    case START_INTERVAL:
      if (selectIsIntervalExists(state, key)) {
        throw registeredIntervalException(key);
      }

      callback(); // force the callback to run for the first time.
      const intervalMiliSec =
        typeof interval === 'number' ? interval : DEFAULT_INTERVAL;
      const intervalID = setInterval(callback, intervalMiliSec, ...args);
      return next(amendActionsPayload(action, { intervalID }));

    case STOP_INTERVAL:
      if (!selectIsIntervalExists(state, key)) {
        throw unregisteredIntervalException(key);
      }
      clearInterval(intervalID);
      return next(action);

    default:
      return next(action);
  }
};

export default IntervalMiddleware;
