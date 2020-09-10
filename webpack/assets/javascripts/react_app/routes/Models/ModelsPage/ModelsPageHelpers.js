import { snakeCase } from 'lodash';
import { compose } from 'redux';
import {
  selectSort,
  selectPage,
  selectPerPage,
  selectSearch,
} from './ModelsPageSelectors';

export const buildQuery = (query, state) => {
  const querySort = pickSort(query, state);

  return {
    page: query.page || selectPage(state),
    perPage: query.perPage || selectPerPage(state),
    searchQuery:
      query.searchQuery === undefined ? selectSearch(state) : query.searchQuery,
    ...(querySort && { sort: querySort }),
  };
};

export const pickSort = (query, state) =>
  checkSort(query.sort)
    ? transformSort(query.sort)
    : checkSort(compose(transformSort, selectSort)(state));

const checkSort = sort => (sort && sort.by && sort.order ? sort : undefined);

const transformSort = sort => ({ ...sort, by: snakeCase(sort.by) });
