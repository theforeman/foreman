import { useEffect, useRef } from 'react';
import { useSelector, useDispatch, shallowEqual } from 'react-redux';
import uuid from 'uuid/v1';
import {
  selectAPIResponse,
  selectAPIStatus,
} from '../../../redux/API/APISelectors';
import { APIActions } from '../../../redux/API';

/**
 * A custom hook that creates an API request
 * @param  {string} method the API method (i.e 'post', 'get' etc)
 * @param  {string} url the url for the API request
 * @param  {object} options adding optional props to the API call, for more details go to the `apiRequest` function in `redux/API`
 * @return {object} returns an object that contains the response, status, key and 'setUrl' for setting the url dynamically
 */

export const useAPI = (method, url, options) => {
  const dispatch = useDispatch();
  const keyRef = useRef(options?.key);

  useEffect(() => {
    if (!keyRef.current) keyRef.current = uuid();
  }, []);

  useEffect(() => {
    if (url && method) {
      dispatch(
        APIActions[method]({
          url,
          ...options,
          key: keyRef.current,
        })
      );
    }
  }, [dispatch, url, method, options]);

  const response = useSelector(
    (state) => selectAPIResponse(state, keyRef.current),
    shallowEqual
  );
  const status = useSelector((state) => selectAPIStatus(state, keyRef.current));

  return { response, status, key: keyRef.current };
};
