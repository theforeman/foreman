import { API } from './';

export const get = async (payload, url, store, actionTypes) => {
  store.dispatch({
    type: actionTypes.REQUEST,
    payload,
  });
  try {
    const { data } = await API.get(
      url,
      payload.headers || {},
      payload.params || {}
    );
    store.dispatch({
      type: actionTypes.SUCCESS,
      payload: { ...payload, ...data },
    });
  } catch (error) {
    store.dispatch({
      type: actionTypes.FAILURE,
      payload: { error, payload },
    });
  }
};
