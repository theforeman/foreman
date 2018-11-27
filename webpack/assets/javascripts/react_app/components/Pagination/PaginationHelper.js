import URI from 'urijs';

export const getURI = () => new URI(window.location.href);

export const getURIpage = () => Number(getURI().query(true).page);
export const getURIperPage = () => Number(getURI().query(true).per_page);

export const changeQuery = (uri, newQuery, navigateTo) => {
  uri.setQuery(newQuery);
  if (navigateTo) {
    navigateTo(uri.toString());
    return uri.toString();
  }
  return window.Turbolinks.visit(uri.toString());
};
