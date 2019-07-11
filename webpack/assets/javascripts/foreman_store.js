import { get } from 'lodash';
import store from './react_app/redux';
import actionsList from './foreman_actions';

/**
 * invoke an action
 * @param  {String}   actionName is the name of the action registered in foreman_actionsList
 * @param  {args} args  action's arguments
 */
export const dispatch = (actionName, ...args) => {
  if (!actionsList[actionName]) {
    throw new ReferenceError(
      `Dispatch failed: action ${actionName} doesn't exist`
    );
  }
  return store.dispatch(actionsList[actionName](...args));
};

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

export function stateExists(state) {
  const stateObj = get(store.getState(), state);

  return !!stateObj;
}
