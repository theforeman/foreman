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

  API.get(url)
    .done(result => dispatch({
      type: successAction,
      payload: { ...item, ...result },
    }))
    .fail((jqXHR, textStatus, error) => dispatch({
      type: failedAction,
      payload: { error, item },
    }));
};
