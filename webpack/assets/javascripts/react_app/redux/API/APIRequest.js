import { API } from './';
import { actionTypeGenerator } from './APIActionTypeGenerator';
import { noop } from '../../common/helpers';

export const get = async (
  {
    key,
    url,
    headers = {},
    params = {},
    actionTypes = {},
    handleError = noop,
    payload = {},
  },
  { dispatch }
) => {
  const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(key, actionTypes);
  const modifiedPayload = { ...payload, url };
  dispatch({
    type: REQUEST,
    key,
    payload: modifiedPayload,
  });
  try {
    const { data } = await API.get(url, headers, params);
    dispatch({
      type: SUCCESS,
      key,
      payload: modifiedPayload,
      response: data,
    });
  } catch (error) {
    handleError(error);
    dispatch({
      type: FAILURE,
      key,
      payload: modifiedPayload,
      response: error,
    });
  }
};
