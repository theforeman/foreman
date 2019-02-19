import URI from 'urijs';

export const getURI = () => new URI(window.location.href);

export const getURIpage = () => Number(getURI().query(true).page);
export const getURIperPage = () => Number(getURI().query(true).per_page);
export const getURISearch = () => getURI().query(true).search;

export const getParams = () => ({
  page: getURIpage() || 1,
  perPage: getURIperPage() || 25,
  searchQuery: getURISearch() || '',
});
export const stringifyParams = ({
  page = 1,
  perPage = 25,
  searchQuery = '',
}) => {
  const uri = getURI();
  if (searchQuery !== '')
    uri.search({ page, per_page: perPage, search: searchQuery });
  else uri.search({ page, per_page: perPage });
  return uri.search();
};

export const changeQuery = (uri, newQuery, navigateTo) => {
  uri.setQuery(newQuery);
  if (navigateTo) {
    navigateTo(uri.toString());
    return uri.toString();
  }
  return window.Turbolinks.visit(uri.toString());
};
