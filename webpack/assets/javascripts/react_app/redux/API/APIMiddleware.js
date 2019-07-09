import { API_OPERATIONS, actionTypeGenerator } from './';
import { get } from './APIRequest';

export const APIMiddleware = store => next => action => {
  const formatDefault = data => data;
  const {
    type,
    key,
    payload = {},
    url,
    actionTypes = {},
    errorFormat = formatDefault,
    successFormat = formatDefault,
    onSuccess = formatDefault,
    onFailure = formatDefault,
  } = action;
  if (type === API_OPERATIONS.GET) {
    get(
      payload,
      url,
      store,
      actionTypeGenerator(key, actionTypes),
      errorFormat,
      successFormat,
      onSuccess,
      onFailure
    );
  } else {
    next(action);
  }
};
