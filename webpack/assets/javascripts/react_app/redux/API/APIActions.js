import { API_OPERATIONS } from './APIConstants';

const { GET, POST, PUT, DELETE, PATCH } = API_OPERATIONS;

/**
 * an API action creator.
 * @param { String } type the API action type.
 * @param { Object } payload the API action payload.
 * @param { String } payload.key the unique key of the API request, will be used in the selector too.
 * @param { String } payload.url the url for the API request.
 * @param { String } payload.headers the API get request headers.
 * @param { Object } payload.params the API get request params.
 * @param { Function } payload.handleError an error handling callback.
 * @param { Function } payload.handleSuccess a success handling callback.
 * @param { Function } payload.errorToast an error toast will be triggered with this message after API error.
 * @param { Function } payload.successToast a succes toast will be triggered with this message after API success.
 * @param { Object } payload.payload the API payload which will be passed also to the reducer.
 * @param { Object } payload.actionTypes action types which will replace the default action types.
 */
export const apiAction = (type, payload) => ({ type, payload });

export const get = (payload) => apiAction(GET, payload);

export const post = (payload) => apiAction(POST, payload);

export const put = (payload) => apiAction(PUT, payload);

export const patch = (payload) => apiAction(PATCH, payload);

export const APIActions = {
  get,
  post,
  put,
  patch,
  delete: (payload) => apiAction(DELETE, payload),
};
