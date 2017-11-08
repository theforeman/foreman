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
