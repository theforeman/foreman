import React from 'react';
import isEmpty from 'lodash/isEmpty';
import PropTypes from 'prop-types';
import URI from 'urijs';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../bookmarks';
import { noop } from '../../common/helpers';

const handleSearch = (searchQuery, onSearch) => {
  if (onSearch) return onSearch(searchQuery);
  const uri = new URI(window.location.href);
  const data = { ...uri.query(true), search: searchQuery.trim(), page: 1 };
  uri.query(URI.buildQuery(data, true));
  return window.Turbolinks.visit(uri.toString());
};

const SearchBar = ({
  className,
  searchQuery,
  error,
  onSearch,
  results,
  status,
  useKeyShortcuts,
  resetData,
  getResults,
  initialUpdate,
  initialQuery,
  showLoading,
  data: { autocomplete, controller, bookmarks },
  ...props
}) => {
  const bookmarksComponent = !isEmpty(bookmarks) ? (
    <Bookmarks data={{ ...bookmarks, controller, searchQuery }} />
  ) : null;
  return (
    <div className={`search-bar input-group ${className}`}>
      <AutoComplete
        {...props}
        controller={controller}
        error={error}
        handleSearch={() => handleSearch(searchQuery, onSearch)}
        initialQuery={initialQuery || autocomplete.searchQuery || ''}
        initialUpdate={initialUpdate}
        getResults={getResults}
        resetData={resetData}
        results={results || autocomplete.results}
        searchQuery={searchQuery}
        status={status}
        showLoading={showLoading}
        useKeyShortcuts={autocomplete.useKeyShortcuts}
        url={autocomplete.url}
      />
      <div className="input-group-btn">
        <AutoComplete.SearchButton
          onClick={() => handleSearch(searchQuery, onSearch)}
        />
        {bookmarksComponent}
      </div>
    </div>
  );
};

SearchBar.propTypes = {
  className: PropTypes.string,
  onSearch: PropTypes.func,
  initialQuery: PropTypes.string,
  searchQuery: PropTypes.string,
  error: PropTypes.string,
  results: PropTypes.array,
  status: PropTypes.string,
  resetData: PropTypes.func,
  getResults: PropTypes.func,
  initialUpdate: PropTypes.func,
  useKeyShortcuts: PropTypes.bool,
  showLoading: PropTypes.bool,
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
  className: '',
  initialQuery: '',
  searchQuery: '',
  onSearch: null,
  error: null,
  results: [],
  status: null,
  resetData: noop,
  getResults: noop,
  initialUpdate: noop,
  showLoading: false,
  useKeyShortcuts: true,
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
