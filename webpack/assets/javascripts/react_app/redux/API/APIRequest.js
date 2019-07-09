import { API } from './';

export const get = async (
  payload,
  url,
  store,
  actionTypes,
  errorFormat,
  successFormat,
  onSuccess,
  onFailure
) => {
  store.dispatch({
    type: actionTypes.REQUEST,
    payload,
  });
  try {
    const response = await API.get(
      url,
      payload.headers || {},
      payload.params || {}
    );
    onSuccess(response);
    store.dispatch({
      type: actionTypes.SUCCESS,
      payload: { ...payload, ...successFormat(response.data) },
    });
  } catch (error) {
    onFailure(error);
    store.dispatch({
      type: actionTypes.FAILURE,
      payload: { ...errorFormat({ error }), payload },
    });
  }
};
