import React from 'react';
import isEmpty from 'lodash/isEmpty';
import PropTypes from 'prop-types';
import URI from 'urijs';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../bookmarks';
import './search-bar.scss';

const handleSearch = searchQuery => {
  const uri = new URI(window.location.href);
  const data = { ...uri.query(true), search: searchQuery.trim(), page: 1 };
  uri.query(URI.buildQuery(data, true));
  window.Turbolinks.visit(uri.toString());
};

const SearchBar = ({
  searchQuery,
  data: { autocomplete, controller, bookmarks },
}) => {
  const bookmarksComponent = !isEmpty(bookmarks) ? (
    <Bookmarks data={{ ...bookmarks, controller, searchQuery }} />
  ) : null;
  return (
    <div className="search-bar input-group">
      <AutoComplete
        handleSearch={() => handleSearch(searchQuery)}
        initialQuery={autocomplete.searchQuery || ''}
        useKeyShortcuts={autocomplete.useKeyShortcuts}
        url={autocomplete.url}
        controller={controller}
      />
      <div className="input-group-btn">
        <AutoComplete.SearchButton onClick={() => handleSearch(searchQuery)} />
        {bookmarksComponent}
      </div>
    </div>
  );
};

SearchBar.propTypes = {
  searchQuery: PropTypes.string,
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      results: PropTypes.array,
      searchQuery: PropTypes.string,
      url: PropTypes.string,
      useKeyShortcuts: PropTypes.bool,
    }),
    controller: PropTypes.string,
    bookmarks: PropTypes.shape({ ...Bookmarks.propTypes }),
  }),
};

SearchBar.defaultProps = {
  searchQuery: '',
  data: {
    autocomplete: {
      results: [],
      searchQuery: null,
      url: null,
      useKeyShortcuts: true,
    },
    controller: null,
    bookmarks: {},
  },
};

export default SearchBar;
