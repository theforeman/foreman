import URI from 'urijs';
import { translate as __ } from '../../common/I18n';

export const getURI = () => new URI(window.location.href);

export const getURIpage = () => Number(getURI().query(true).page);
export const getURIperPage = () => Number(getURI().query(true).per_page);

export const translatePagination = (strings) => {
  const translations = {};
  Object.keys(strings).forEach((str) => {
    translations[str] = __(strings[str]);
  });
  return translations;
};

export const changeQuery = (uri, newQuery, navigateTo) => {
  uri.setQuery(newQuery);
  if (navigateTo) { navigateTo(uri.toString()); return uri.toString(); }
  return window.Turbolinks.visit(uri.toString());
};
