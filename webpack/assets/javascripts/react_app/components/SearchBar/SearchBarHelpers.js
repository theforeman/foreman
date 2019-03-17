import URI from 'urijs';

export const resolveSearchQuery = searchQuery => {
  const uri = new URI(window.location.href);
  const data = { ...uri.query(true), search: searchQuery.trim(), page: 1 };
  uri.query(URI.buildQuery(data, true));
  window.Turbolinks.visit(uri.toString());
};
