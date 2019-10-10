import history from '../../../history';
import { API_OPERATIONS } from '../../../redux/API';
import { buildQuery } from './ModelsPageHelpers';

import { MODELS_API_PATH, MODELS_PATH, API_REQUEST_KEY } from '../constants';

import { stringifyParams, getParams } from '../../../common/urlHelpers';

export const initializeModels = () => dispatch => {
  const params = getParams();
  dispatch(fetchModels(params));
  if (!history.action === 'POP') {
    history.replace({
      pathname: MODELS_PATH,
      search: stringifyParams(params),
    });
  }
};

export const fetchModels = (
  { page, perPage, searchQuery, sort },
  url = MODELS_API_PATH
) => async dispatch => {
  const sortString =
    sort && Object.keys(sort).length > 0 ? `${sort.by} ${sort.order}` : '';

  return dispatch({
    type: API_OPERATIONS.GET,
    payload: {
      key: API_REQUEST_KEY,
      url,
      payload: {
        page,
        per_page: perPage,
        search: searchQuery,
        order: sortString,
      },
    },
  });
};

export const fetchAndPush = (params = {}) => (dispatch, getState) => {
  const query = buildQuery(params, getState());
  dispatch(fetchModels(query));
  history.push({
    pathname: MODELS_PATH,
    search: stringifyParams(query),
  });
};
