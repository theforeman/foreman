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
