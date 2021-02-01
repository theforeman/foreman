import React from 'react';
import { shallow } from '@theforeman/test';

jest.useFakeTimers();

export default {
  mockStorage: () => {
    const storage = {};

    return {
      setItem: (key, value) => {
        storage[key] = value || '';
      },
      getItem: key => (key in storage ? storage[key] : null),
      removeItem: key => {
        delete storage[key];
      },
      get length() {
        return Object.keys(storage).length;
      },
      key: i => {
        const keys = Object.keys(storage);

        return keys[i] || null;
      },
    };
  },
};

export const mockWindowLocation = ({ href }) => {
  let currentHref = href;
  delete global.window.location;
  global.window.location = { reload: jest.fn() };
  Object.defineProperty(global.window.location, 'href', {
    configurable: true,
    get: () => currentHref,
    set: newValue => {
      currentHref = newValue;
    },
  });
  return jest.spyOn(global.window.location, 'href', 'set');
};

// a helper method for invoking a class method (for unit tests)
// obj = a class
// func = a tested function
// objThis = an object's this
// arg = function args

export const classFunctionUnitTest = (obj, func, objThis, args) =>
  obj.prototype[func].apply(objThis, args);

/**
 * Shallow render a component multipile times with fixtures
 * @param  {ReactComponent} Component Component to shallow-render
 * @param  {Object}         fixtures  key=fixture description, value=props to apply
 * @return {Object}                   key=fixture description, value=shallow-rendered component
 */
export const shallowRenderComponentWithFixtures = (Component, fixtures) =>
  Object.entries(fixtures).map(([description, props]) => ({
    description,
    component: shallow(<Component {...props} />),
  }));

/**
 * Test a component with fixtures and snapshots
 * @param  {ReactComponent} Component Component to test
 * @param  {Object}         fixtures  key=fixture description, value=props to apply
 */
export const testComponentSnapshotsWithFixtures = (Component, fixtures) =>
  shallowRenderComponentWithFixtures(
    Component,
    fixtures
  ).forEach(({ description, component }) =>
    it(description, () => expect(component).toMatchSnapshot())
  );

const resolveDispatch = async (action, depth) => {
  // if it is async action and we are allowed to go deeper
  if (depth && typeof action === 'function') {
    const dispatch = jest.fn();
    await action(dispatch);
    jest.runOnlyPendingTimers();

    return Promise.all(
      dispatch.mock.calls.map(call => resolveDispatch(call[0], depth - 1))
    );
  }
  // else return the action itself
  return action;
};

/**
 * run an action (sync or async) and returns a call tree
 * @param  {Function}  runAction  Action runner function
 * @param  {Number} states the depth of dispatch calls
 * @return calls result tree to the given depth - array for each branch of calls
 */
export const runActionInDepth = (runAction, depth = 1) =>
  resolveDispatch(runAction(), depth);

/**
 * run an action (sync or async) and except the results to much snapshot
 * @param  {Function}  runAction  Action runner function
 * @return {Promise}
 */
export const testActionSnapshot = async runAction => {
  const actionResults = runAction();

  // if it's an async action
  if (typeof actionResults === 'function') {
    const dispatch = jest.fn();
    await actionResults(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
  } else {
    expect(actionResults).toMatchSnapshot();
  }
};

/**
 * Test actions with fixtures and snapshots
 * @param  {Object} fixtures key=fixture description, value=action runner function
 */
export const testActionSnapshotWithFixtures = fixtures =>
  Object.entries(fixtures).forEach(([description, runAction]) =>
    it(description, () => testActionSnapshot(runAction))
  );

/**
 * Test a reducer with fixtures and snapshots
 * @param  {Function} reducer  reducer to test
 * @param  {Object}   fixtures key=fixture description, value=props to apply
 */
export const testReducerSnapshotWithFixtures = (reducer, fixtures) => {
  const reduce = ({ state, action = {} } = {}) => reducer(state, action);
  Object.entries(fixtures).forEach(([description, action]) =>
    it(description, () => expect(reduce(action)).toMatchSnapshot())
  );
};

/**
 * Test selectors with fixtures and snapshots
 * @param  {Object} fixtures  key=fixture description,
 *                            value=selector runner function
 */
export const testSelectorsSnapshotWithFixtures = fixtures =>
  Object.entries(fixtures).forEach(([description, selectorRunner]) =>
    it(description, () => expect(selectorRunner()).toMatchSnapshot())
  );

/**
 * Mock Date.now() with a custom time
 * @param  {Object} time  time in ms (i.e 1530518207007)
 * @return {Function} returns a callback to stop mocking the global Date
 */
export const mockNowDate = time => {
  const realDateNow = Date.now.bind(global.Date);
  const dateNowStub = jest.fn(() => time);
  global.Date.now = dateNowStub;
  return () => {
    global.Date.now = realDateNow;
  };
};
