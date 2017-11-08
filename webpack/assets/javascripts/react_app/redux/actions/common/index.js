import API from '../../../API';

export const ajaxRequestAction = ({
  dispatch,
  requestAction,
  successAction,
  failedAction,
  url,
  item,
}) => {
  dispatch({ type: requestAction, payload: item });
  API.get(url).then(
    result => dispatch({ type: successAction, payload: Object.assign(item, result) }),
    (jqXHR, textStatus, error) => dispatch({ type: failedAction, payload: { error, item } }),
  );
};
