import { omit } from 'lodash';
import { STOP_INTERVAL } from './IntervalConstants';
import { selectDoesIntervalExist, selectIntervalID } from './IntervalSelectors';
import {
  registeredIntervalException,
  unregisteredIntervalException,
  getDefaultInterval,
} from './IntervalHelpers';
import { startInterval as startIntervalAction } from './IntervalActions';
import { whenDocumentIsVisible } from '../common/helpers';

export const IntervalMiddleware = store => next => action => {
  const { type, key, interval } = action;

  if (interval) {
    if (selectDoesIntervalExist(store.getState(), key)) {
      throw registeredIntervalException(key);
    }

    // To avoid the action from getting into an endless loop in this middleware.
    const modifiedAction = omit(action, ['interval']);
    const dispatchModifiedAction = () => store.dispatch(modifiedAction);

    dispatchModifiedAction(); // force the action to run for the first time.
    const delay =
      typeof interval === 'number' ? interval : getDefaultInterval();
    const intervalFunc = () => whenDocumentIsVisible(dispatchModifiedAction);
    const intervalID = setInterval(intervalFunc, delay);
    return store.dispatch(startIntervalAction(key, intervalID));
  }

  if (type === STOP_INTERVAL) {
    const state = store.getState();

    if (!selectDoesIntervalExist(state, key)) {
      throw unregisteredIntervalException(key);
    }

    const intervalID = selectIntervalID(state, key);
    clearInterval(intervalID);
  }

  return next(action);
};

export default IntervalMiddleware;
