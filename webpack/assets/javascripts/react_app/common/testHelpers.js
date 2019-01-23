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

// a helper method for invoking a class method (for unit tests)
// obj = a class
// func = a tested function
// objThis = an object's this
// arg = function args

export const classFunctionUnitTest = (obj, func, objThis, args) =>
  obj.prototype[func].apply(objThis, args);

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
