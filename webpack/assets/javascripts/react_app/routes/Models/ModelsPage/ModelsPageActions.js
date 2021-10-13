import URI from 'urijs';
import history from '../../../history';
import { get } from '../../../redux/API';
import { buildQuery } from './ModelsPageHelpers';

import { MODELS_API_PATH, MODELS_PATH, API_REQUEST_KEY } from '../constants';

import { stringifyParams, getParams } from '../../../common/urlHelpers';

export const initializeModels = () => (dispatch) => {
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
) => {
  const sortString =
    sort && Object.keys(sort).length > 0 ? `${sort.by} ${sort.order}` : '';

  const uriWithPrams = new URI(url);
  uriWithPrams.setSearch({
    page,
    per_page: perPage,
    search: searchQuery,
    order: sortString,
  });
  return get({ key: API_REQUEST_KEY, url: uriWithPrams });
};

export const fetchAndPush =
  (params = {}) =>
  (dispatch, getState) => {
    const query = buildQuery(params, getState());
    dispatch(fetchModels(query));
    history.push({
      pathname: MODELS_PATH,
      search: stringifyParams(query),
    });
  };
