if (!window.sessionStorage) {
  window.sessionStorage = {
    getItem: () => {},
    setItem: () => {},
  };
}

export const getValue = (key) => {
  const value = window.sessionStorage.getItem(key) || 'null';

  return JSON.parse(value);
};

export const setValue = (key, value) =>
  window.sessionStorage.setItem(key, JSON.stringify(value));
