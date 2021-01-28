/* eslint-disable no-console */
import { getApiResponse } from './APIHelpers';
import { actionTypeGenerator } from './APIActionTypeGenerator';
import { noop } from '../../common/helpers';
import { stopInterval } from '../middlewares/IntervalMiddleware';
import { selectDoesIntervalExist } from '../middlewares/IntervalMiddleware/IntervalSelectors';
import { addToast } from '../actions/toasts';

export const apiRequest = async (
  {
    type,
    payload: {
      key,
      url,
      headers = {},
      params = {},
      actionTypes = {},
      handleError = noop,
      handleSuccess = noop,
      successToast,
      errorToast,
      payload = {},
    },
  },
  { dispatch, getState }
) => {
  const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(key, actionTypes);
  const modifiedPayload = { ...payload, url };
  const stopIntervalCallback = selectDoesIntervalExist(getState(), key)
    ? () => dispatch(stopInterval(key))
    : () => console.warn(`There's no interval API request for the key: ${key}`);

  dispatch({
    type: REQUEST,
    key,
    payload: modifiedPayload,
  });

  try {
    const response = await getApiResponse({ type, url, headers, params });

    dispatch({
      type: SUCCESS,
      key,
      payload: modifiedPayload,
      response: response.data,
    });

    successToast &&
      dispatch(
        addToast({
          type: 'success',
          message: successToast(response),
          key: SUCCESS,
        })
      );

    handleSuccess(response, stopIntervalCallback);
  } catch (error) {
    dispatch({
      type: FAILURE,
      key,
      payload: modifiedPayload,
      response: error,
    });

    errorToast &&
      dispatch(
        addToast({ type: 'error', message: errorToast(error), key: FAILURE })
      );

    handleError(error, stopIntervalCallback);
  }
};
