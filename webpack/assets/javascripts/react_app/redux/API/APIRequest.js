import { getApiResponse } from './APIHelpers';
import { actionTypeGenerator } from './APIActionTypeGenerator';
import { noop } from '../../common/helpers';

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
      payload = {},
    },
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
    const response = await getApiResponse({ type, url, headers, params });
    dispatch({
      type: SUCCESS,
      key,
      payload: modifiedPayload,
      response: response.data,
    });
    handleSuccess(response);
  } catch (error) {
    dispatch({
      type: FAILURE,
      key,
      payload: modifiedPayload,
      response: error,
    });
    handleError(error);
  }
};
