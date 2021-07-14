import URI from 'urijs';
import { push } from 'connected-react-router';
import { get } from '../../../../../redux/API';
import { selectQueryParams } from './TableSelectors';
import { getTableAPIKey } from './TableHelpers';

export const fetchData = (path, queryParams = {}) => (dispatch, getState) => {
  const state = getState();
  const { page, perPage, query, sortBy, sortOrder } = {
    ...selectQueryParams(state),
    ...queryParams,
  };

  dispatch(
    get({
      key: getTableAPIKey(path),
      url: path,
      params: {
        page,
        per_page: perPage,
        search: query,
        order: `${sortBy} ${sortOrder}`,
      },
    })
  );

  const uri = new URI();
  uri.search({
    page,
    per_page: perPage,
    search: query,
    sort_by: sortBy,
    sort_order: sortOrder,
  });

  dispatch(
    push({
      pathname: uri.pathname(),
      search: uri.search(),
    })
  );
};

export const onTableSort = (index, direction, columns, path) => {
  const { sortKey } = columns[index];
  return fetchData(path, {
    sortBy: sortKey,
    sortOrder: direction,
    page: 1,
  });
};

export const onTableSetPage = (page, path) => fetchData(path, { page });

export const onTablePerPageSelect = (perPage, path) =>
  fetchData(path, { perPage, page: 1 });
