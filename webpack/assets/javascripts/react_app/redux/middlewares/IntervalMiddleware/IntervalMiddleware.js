import { omit } from 'lodash';
import { STOP_INTERVAL } from './IntervalConstants';
import { selectDoesIntervalExist, selectIntervalID } from './IntervalSelectors';
import {
  registeredIntervalException,
  getDefaultInterval,
} from './IntervalHelpers';
import { startInterval as startIntervalAction } from './IntervalActions';
import { whenDocumentIsVisible } from '../common/helpers';

export const IntervalMiddleware = store => next => action => {
  const { type, key, interval, payload = {} } = action;
  const intervalKey = key || payload.key;

  if (interval) {
    if (selectDoesIntervalExist(store.getState(), intervalKey)) {
      throw registeredIntervalException(intervalKey);
    }

    // To avoid the action from getting into an endless loop in this middleware.
    const modifiedAction = omit(action, ['interval']);
    const dispatchModifiedAction = () => store.dispatch(modifiedAction);

    dispatchModifiedAction(); // force the action to run for the first time.
    const delay =
      typeof interval === 'number' ? interval : getDefaultInterval();
    const intervalFunc = () => whenDocumentIsVisible(dispatchModifiedAction);
    const intervalID = setInterval(intervalFunc, delay);
    return store.dispatch(startIntervalAction(intervalKey, intervalID));
  }

  if (type === STOP_INTERVAL) {
    const state = store.getState();
    const intervalID = selectIntervalID(state, intervalKey);
    return intervalID && clearInterval(intervalID);
  }

  return next(action);
};

export default IntervalMiddleware;
