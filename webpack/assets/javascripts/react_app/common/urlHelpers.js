import URI from 'urijs';

import { visit } from '../../foreman_navigation';

/**
 * Build a url from given controller, action and id
 * @param {String} controller - the controller
 * @param {String} action - the action
 */
export const urlBuilder = (controller, action, id = undefined) =>
  `/${controller}/${id ? `${id}/` : ''}${action}`;

/**
 * Build a url with search query
 * @param {String} base - the base url
 * @param {String} searchQuery - the search query
 */
export const urlWithSearch = (base, searchQuery) =>
  `/${base}?search=${searchQuery}`;

/**
 * Get updated URI
 */
export const getURI = () => new URI(window.location.href);

/**
 * Get updated page param
 */
export const getURIpage = () => Number(getURI().query(true).page) || 1;
/**
 * Get updated perPage param
 */
export const getURIperPage = () => Number(getURI().query(true).per_page);
/**
 * Get updated searchQuery param
 */
export const getURIsearch = () => getURI().query(true).search || '';

/**
 * Get updated sort param
 */
export const getURIsort = () => {
  const sortString = getURI().query(true).order;
  if (!sortString) {
    return {};
  }
  const [by, order] = sortString.split(' ');
  return { by, order };
};

/**
 * Get updated URI params
 */
export const getParams = () => ({
  page: getURIpage(),
  perPage: getURIperPage() || null,
  searchQuery: getURIsearch(),
  sort: getURIsort(),
});

/**
 * Get updated Stringified params
 */
export const stringifyParams = ({
  page = 1,
  perPage = 25,
  searchQuery = '',
  sort = {},
}) => {
  const uri = getURI();
  if (searchQuery !== '')
    uri.search({ page, per_page: perPage, search: searchQuery });
  else uri.search({ page, per_page: perPage });

  if (sort.by && sort.order) {
    uri.setSearch('order', `${sort.by} ${sort.order}`);
  }

  return uri.search();
};

/**
 * change current query and trigger navigation
 * @param {URI} uri - URI object
 * @param {Object} newQuery  - Query Object
 * @param {Function} navigateTo  - navigate func
 */
export const changeQuery = (newQuery, navigateTo, uri = getURI()) => {
  uri.setQuery(newQuery);
  if (navigateTo) navigateTo(uri.toString());
  else visit(uri.toString());
};

export const exportURL = () => {
  const url = getURI();
  url.addQuery('format', 'csv');
  return `${url.pathname()}${url.search()}`;
};
