import { useEffect, useState } from 'react';

/**
 * A custom hook that listens for enter on a ref and runs a function on enter keydown
 * @param  {object} ref a ref created with React's useRef or createRef that scopes the event listener
 * @param  {function} onSubmit function to execute on enter keydown
 */
export const useSubmitOnEnter = (ref, onSubmit) => {
  const [listenerAdded, setListenerAdded] = useState(false);

  useEffect(() => {
    const listener = event => {
      if (event.code === 'Enter' || event.code === 'NumpadEnter') onSubmit();
    };

    const refPointer = ref; // re-assigning so it's available on unmount
    // A check is added so we don't keep attaching the same event listener. The listener function
    // is created in the hook, so the browser will attach multiple "new" event listeners.
    if (!listenerAdded) {
      /* eslint-disable-next-line no-unused-expressions */
      refPointer?.current?.addEventListener?.('keydown', listener);
      setListenerAdded(true);
    }

    return () =>
      refPointer?.current?.removeEventListener?.('keydown', listener);
  }, [ref, listenerAdded, onSubmit]);
};

export default useSubmitOnEnter;
