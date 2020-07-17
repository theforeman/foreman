import { useEffect } from 'react';

/**
 * A custom hook that listens for enter on a ref and runs a function on enter keydown
 * @param  {object} ref a ref created with React's useRef or createRef that scopes the event listener
 * @param  {function} onSubmit function to execute on enter keydown
 */
export const useSubmitOnEnter = (ref, onSubmit) => {
  const listener = event => {
    if (event.code === 'Enter' || event.code === 'NumpadEnter') onSubmit();
  };

  useEffect(() => {
    const refPointer = ref; // re-assigning so it's available on unmount
    /* eslint-disable-next-line no-unused-expressions */
    refPointer?.current?.addEventListener?.('keydown', listener);

    return () =>
      refPointer?.current?.removeEventListener?.('keydown', listener);
  }, []);
};

export default useSubmitOnEnter;
