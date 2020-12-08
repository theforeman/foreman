import { API } from '../../../redux/API';

export const ajaxRequestAction = async ({
  dispatch,
  requestAction,
  successAction,
  failedAction,
  url,
  item = {},
}) => {
  dispatch({ type: requestAction, payload: item });
  try {
    const { data } = await API.get(url, item.headers || {}, item.params || {});
    return dispatch({ type: successAction, payload: { ...item, ...data } });
  } catch (error) {
    return dispatch({ type: failedAction, payload: { error, item } });
  }
};
