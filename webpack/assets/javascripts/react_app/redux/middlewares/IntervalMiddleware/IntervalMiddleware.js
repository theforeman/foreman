import { omit } from 'lodash';
import { STOP_INTERVAL, DEFAULT_INTERVAL } from './IntervalConstants';
import { selectDoesIntervalExist, selectIntervalID } from './IntervalSelectors';
import {
  registeredIntervalException,
  unregisteredIntervalException,
} from './IntervalHelpers';
import { startIntervalAction } from './IntervalActions';

export const IntervalMiddleware = store => next => action => {
  const { type, key, interval } = action;
  const state = store.getState();
  /**
    for the action to run multiple times
    without getting into an endless loop in this middleware.
  */

  const modifiedAction = omit(action, ['interval']);
  const dispatchModifiedAction = () => store.dispatch(modifiedAction);

  if (interval) {
    if (selectDoesIntervalExist(state, key)) {
      throw registeredIntervalException(key);
    }

    dispatchModifiedAction(); // force the action to run for the first time.
    const intervalMiliSec =
      typeof interval === 'number' ? interval : DEFAULT_INTERVAL;
    const intervalID = setInterval(dispatchModifiedAction, intervalMiliSec);
    return store.dispatch(startIntervalAction(key, intervalID));
  }

  if (type === STOP_INTERVAL) {
    if (!selectDoesIntervalExist(state, key)) {
      throw unregisteredIntervalException(key);
    }
    const intervalID = selectIntervalID(state, key);
    clearInterval(intervalID);
  }

  return next(action);
};

export default IntervalMiddleware;
