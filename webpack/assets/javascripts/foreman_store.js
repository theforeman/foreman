import { get } from 'lodash';
import store from './react_app/redux';

/**
 * Observe a state from the store for changes
 * @param  {String}   state a sub object of the store
 * @param  {Function} onChange  a callback to run when the store has been changed
 * @return {Function}           unsubscribe function
 */
export function observeStore(state, onChange) {
  let currentState;

  function handleChange() {
    const nextState = select(state);
    if (nextState !== currentState) {
      currentState = nextState;
      onChange(currentState, unsubscribe);
    }
  }

  const unsubscribe = store.subscribe(handleChange);
  handleChange();
  return unsubscribe;
}

function select(state) {
  const stateObj = get(store.getState(), state);

  if (stateObj === undefined) {
    throw new Error(`State ${state} does not exist`);
  }

  return stateObj;
}
