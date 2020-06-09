import { API_OPERATIONS } from './APIConstants';

const { GET } = API_OPERATIONS;

/**
 * an API action creator for API get.
 * @param { Object } payload payload for the API get acion.
 * @param { String } payload.key the unique key of the API request, will be used in the selector too.
 * @param { String } payload.url the url for the API request.
 * @param { String } payload.headers the API get request headers.
 * @param { Object } payload.params the API get request params.
 * @param { Object } payload.handleError an error handling callback.
 * @param { Object } payload.handleSuccess a success handling callback.
 * @param { Object } payload.payload the API payload which will be passed also to the reducer.
 * @param { Object } payload.actionTypes action types which will replace the default action types.
 */
export const get = payload => ({ type: GET, payload });
