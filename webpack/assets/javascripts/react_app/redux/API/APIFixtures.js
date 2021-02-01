import { API_OPERATIONS } from './APIConstants';

export const key = 'SOME_KEY';
export const url = 'some/url';
export const params = { page: 1, per_page: 25 };
export const headers = {};
export const id = 2;
export const payload = { id };
export const error = new Error('some_error');
export const data = { results: [1] };
export const actionTypes = {
  REQUEST: `${key}_REQUEST`,
  SUCCESS: `${key}_SUCCESS`,
  FAILURE: `${key}_FAILURE`,
  UPDATE: `${key}_UPDATE`,
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

export const postActionWithCallback = {
  type: API_OPERATIONS.POST,
  payload: {
    key: 'INITIAL_RESOURCE',
    url,
    actionTypes,
    updateData: prevState => ({
      ...prevState,
      results: prevState.results.map(i => i + 1),
    }),
    payload,
  },
};

export const middlewareActions = {
  request: {
    type: actionTypes.REQUEST,
    key,
    payload,
  },
  success: {
    key,
    type: actionTypes.SUCCESS,
    payload,
    response: data,
  },
  failure: {
    key,
    type: actionTypes.FAILURE,
    payload,
    response: error,
  },
  update: {
    key,
    type: actionTypes.UPDATE,
    payload: 'UPDATED CONTENT',
  },
};
