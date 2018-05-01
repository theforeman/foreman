import React from 'react';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';

export default {
  mockStorage: () => {
    const storage = {};

    return {
      setItem: (key, value) => {
        storage[key] = value || '';
      },
      getItem: key => (key in storage ? storage[key] : null),
      removeItem: (key) => {
        delete storage[key];
      },
      get length() {
        return Object.keys(storage).length;
      },
      key: (i) => {
        const keys = Object.keys(storage);

        return keys[i] || null;
      },
    };
  },
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
  shallowRenderComponentWithFixtures(Component, fixtures).forEach(({ description, component }) =>
    it(description, () => expect(toJson(component)).toMatchSnapshot()));

/**
 * run an action (sync or async) and except the results to much snapshot
 * @param  {Function}  runAction  Action runner function
 * @return {Promise}
 */
export const testActionSnapshot = async (runAction) => {
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
    it(description, () => testActionSnapshot(runAction)));

/**
 * Test a reducer with fixtures and snapshots
 * @param  {Function} reducer  reducer to test
 * @param  {Object}   fixtures key=fixture description, value=props to apply
 */
export const testReducerSnapshotWithFixtures = (reducer, fixtures) => {
  const reduce = ({ state, action = {} } = {}) => reducer(state, action);
  Object.entries(fixtures).forEach(([description, action]) =>
    it(description, () => expect(reduce(action)).toMatchSnapshot()));
};
