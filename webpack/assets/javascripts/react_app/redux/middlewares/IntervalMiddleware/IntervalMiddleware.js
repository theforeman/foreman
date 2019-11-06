import { START_INTERVAL, STOP_INTERVAL } from './IntervalConstants';
import { selectIntervalID } from './IntervalSelectors';
import { amendActionsPayload } from '../common/helpers';
import {
  registeredIntervalException,
  unregisteredIntervalException,
} from './IntervalHelpers';

export const IntervalMiddleware = store => next => action => {
  const { type, payload: { key, method, interval, args } = {} } = action;
  const state = store.getState();

  if (type === START_INTERVAL) {
    const intervalAlreadyExist = !!selectIntervalID(state, key);

    if (intervalAlreadyExist) {
      throw registeredIntervalException(key);
    }

    method(); // force the method to run for the first time.
    const intervalID = setInterval(method, interval, ...args);
    return next(amendActionsPayload(action, { intervalID }));
  }

  if (type === STOP_INTERVAL) {
    const intervalID = selectIntervalID(state, key);

    if (!intervalID) {
      throw unregisteredIntervalException(key);
    }
    clearInterval(intervalID);
  }
  return next(action);
};

export default IntervalMiddleware;
