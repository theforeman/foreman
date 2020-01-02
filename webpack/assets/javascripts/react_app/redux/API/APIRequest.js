import { API } from './';
import { actionTypeGenerator } from './APIActionTypeGenerator';

export const get = async (
  { key, url, headers = {}, params = {}, actionTypes = {}, payload = {} },
  { dispatch }
) => {
  const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(key, actionTypes);
  dispatch({
    type: REQUEST,
    payload,
  });
  try {
    const { data } = await API.get(url, headers, params);
    dispatch({
      type: SUCCESS,
      payload,
      response: data,
    });
  } catch (error) {
    dispatch({
      type: FAILURE,
      payload,
      response: error,
    });
  }
};
