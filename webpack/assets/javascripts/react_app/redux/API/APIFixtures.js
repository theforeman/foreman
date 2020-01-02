import { API_OPERATIONS } from './APIConstants';

export const key = 'SOME_KEY';
export const url = 'some/url';
export const params = { page: 1, per_page: 25 };
export const headers = {};
export const payload = { id: 2 };
export const actionTypes = {
  REQUEST: 'CUSTOM_REQUEST',
  SUCCESS: 'CUSTOM_SUCCESS',
  FAILURE: 'CUSTOM_FAILURE',
};

export const action = {
  type: API_OPERATIONS.GET,
  payload: {
    key,
    url,
    headers,
    params,
    actionTypes,
    payload,
  },
};
