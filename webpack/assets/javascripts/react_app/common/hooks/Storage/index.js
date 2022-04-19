import { useState, useEffect, useRef } from 'react';

const getStorageValue = (key, defaultValue, storage) => {
  const saved = storage.current.getItem(key);
  const initial = JSON.parse(saved);
  return initial !== undefined ? initial : defaultValue;
};

/**
 * A custom hook that creates a memoized state in local storage
 * @param  {string} key a unique id for the state
 * @param  {string} defaultValue a default value for the state
 * @param  {boolean} session whether to use session storage or local storage
 * @return {Array} returns an array that contains the state's value and the setter function
 */

export const useLocalStorage = (key, defaultValue, session = false) => {
  const storage = useRef(session ? sessionStorage : localStorage);
  const [value, setValue] = useState(() =>
    getStorageValue(key, defaultValue, storage)
  );

  useEffect(() => {
    storage.current.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue];
};
