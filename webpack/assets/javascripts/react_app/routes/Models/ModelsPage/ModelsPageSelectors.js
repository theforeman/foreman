import { camelCase } from 'lodash';
import Immutable from 'seamless-immutable';

import { API_REQUEST_KEY } from '../constants';
import { STATUS } from '../../../constants';
import { deepPropsToCamelCase } from '../../../common/helpers';

export const response = {
  results: [],
  page: 0,
  perPage: 0,
  search: '',
  sort: {},
  canCreate: false,
  subtotal: 0,
  message: {},
};

const emptyState = Immutable({
  payload: null,
  response,
  status: null,
});

export const selectModelsPageData = state =>
  deepPropsToCamelCase(state.API[API_REQUEST_KEY]) || emptyState;

const selectModelsPageResponse = state =>
  selectModelsPageData(state).response || Immutable(response);

export const selectIsLoading = state => {
  const { status } = selectModelsPageData(state);
  return !status || status === STATUS.PENDING;
};

const selectModelsPageStatus = state => selectModelsPageData(state).status;

export const selectHasError = state =>
  selectModelsPageStatus(state) === STATUS.ERROR;

export const selectModels = state => selectModelsPageResponse(state).results;

export const selectHasData = state => {
  const status = selectModelsPageStatus(state);
  const results = selectModels(state);

  return status === STATUS.RESOLVED && results && results.length > 0;
};

export const selectPage = state => selectModelsPageResponse(state).page;
export const selectPerPage = state => selectModelsPageResponse(state).perPage;
export const selectSearch = state => selectModelsPageResponse(state).search;

export const selectSort = state => {
  const sort = selectModelsPageResponse(state).sort || Immutable({});
  if (sort.by && sort.order) {
    return { ...sort, by: camelCase(sort.by) };
  }
  return sort;
};

export const selectCanCreate = state =>
  selectModelsPageResponse(state).canCreate;
export const selectSubtotal = state => selectModelsPageResponse(state).subtotal;
export const selectMessage = state => selectModelsPageResponse(state).message;
