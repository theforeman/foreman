import { omit } from 'lodash';
import { selectDebounceItem } from './DebounceSelectors';
import {
  startDebounce,
  clearDebounce,
  stopIncomingAction,
} from './DebounceActions';

export const DebounceMiddleware = store => next => action => {
  const { key, debounce, payload = {} } = action;
  const debounceKey = key || payload.key;
  const state = store.getState();

  if (!debounce) {
    return next(action);
  }

  if (selectDebounceItem(state, debounceKey)) {
    return store.dispatch(stopIncomingAction(key));
  }

  const modifiedAction = omit(action, ['debounce']);
  return store.dispatch(
    startDebounce({
      key: debounceKey,
      debounceID: setTimeout(() => {
        store.dispatch(modifiedAction);
        store.dispatch(clearDebounce(debounceKey));
      }, debounce),
    })
  );
};

export default DebounceMiddleware;
