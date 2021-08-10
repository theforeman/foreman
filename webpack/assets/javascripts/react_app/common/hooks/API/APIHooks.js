import { useEffect, useState } from 'react';
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

export const useAPI = (method, url, options = {}) => {
  const dispatch = useDispatch();
  const { key, ...rest } = options;
  const [keyState, setKeyState] = useState(key || uuid());
  const [APIoptions, setAPIOptions] = useState(rest);

  useEffect(() => {
    if (key) setKeyState(key);
  }, [key]);

  useEffect(() => {
    if (url && method) {
      dispatch(
        APIActions[method]({
          url,
          ...APIoptions,
          key: keyState,
        })
      );
    }
  }, [dispatch, url, method, keyState, APIoptions]);

  const response = useSelector(
    state => selectAPIResponse(state, keyState),
    shallowEqual
  );
  const status = useSelector(state => selectAPIStatus(state, keyState));

  return { response, status, key: keyState, setAPIOptions };
};
