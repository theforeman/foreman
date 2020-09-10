import React from 'react';
import { mount } from '@theforeman/test';
import { Provider } from 'react-redux';
import { applyMiddleware, combineReducers, createStore } from 'redux';
import thunk from 'redux-thunk';

export default class IntegrationTestHelper {
  /**
   * Wait for all the promises in the test to get resolved
   * @return {Promise}
   */
  static flushAllPromises() {
    return new Promise(resolve => setImmediate(resolve));
  }
  /**
   * Create an integration-test-helper
   * @param {ReduxReducers} reducers reducers to apply
   */
  constructor(reducers, middlewares = []) {
    this.dispatchSpy = jest.fn(() => ({}));
    const reducerSpy = (state, action) => this.dispatchSpy(action);
    const emptyStore = applyMiddleware(thunk, ...middlewares)(createStore);
    const combinedReducers = combineReducers({
      reducerSpy,
      ...reducers,
    });

    this.store = emptyStore(combinedReducers);
  }
  /**
   * Mount a component with the store
   * @param  {ReactNode} component A react node to mount
   * @return {EnzymeMount}         Mounted component with enzyme and redux store
   */
  mount(component) {
    return mount(<Provider store={this.store}>{component}</Provider>);
  }
  /**
   * Get the current state object
   * @return {Object} Current state
   */
  getState() {
    const state = this.store.getState();
    delete state.reducerSpy;
    return state;
  }
  /**
   * Get a list with all dispatch calls
   * @return {Array} Dispatch calls
   */
  getDispatchCalls() {
    const isRelevantCall = call =>
      call.filter(({ type }) => type.startsWith('@@redux')).length === 0;

    return this.dispatchSpy.mock.calls.filter(isRelevantCall);
  }
  /**
   * Get the last dispatch call
   * @return {Array} dispatch call
   */
  getLastDispachCall() {
    return this.getDispatchCalls().slice(-1);
  }
  /**
   * Compare the store with the stored snapshot
   * @param  {string} description Snapshot description
   */
  takeStoreSnapshot(description) {
    expect(this.getState()).toMatchSnapshot(description);
  }
  /**
   * Take a snapshot of all the actions
   * @param  {string} description Snapshoot description
   */
  takeActionsSnapshot(description = 'Integration test actions') {
    expect(this.getDispatchCalls()).toMatchSnapshot(description);
  }
  /**
   * Take a snapshot of the last called action
   * @param  {string} description Snapshoot description
   */
  takeLastActionSnapshot(description) {
    expect(this.getLastDispachCall()).toMatchSnapshot(description);
  }
  /**
   * Take a snapshot of the store together with the last action call
   * @param  {string} description Snapshot description
   */
  takeStoreAndLastActionSnapshot(description) {
    const state = this.getState();
    const action = this.getLastDispachCall();

    expect({ state, action }).toMatchSnapshot(description);
  }
}
