import { useEffect, useRef } from 'react';

/**
 * A custom hook that creates a useEffect that function as a componentDidUpdate - triggers only from second render
 * @param  {Function} func useEffect's callback
 * @param  {Array} deps useEffect's dependecy array
 */
export const useDidUpdateEffect = (func, deps) => {
  const didMount = useRef(false);

  useEffect(() => {
    if (didMount.current) {
      func();
    } else {
      didMount.current = true;
    }
  }, deps); // eslint-disable-line react-hooks/exhaustive-deps
};
