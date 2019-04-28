import React from 'react';
import isEmpty from 'lodash/isEmpty';
import PropTypes from 'prop-types';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../bookmarks';
import { resolveSearchQuery } from './SearchBarHelpers';
import './search-bar.scss';

const SearchBar = ({
  data: { autocomplete, controller, bookmarks },
  searchQuery,
  onSearch,
  initialQuery,
}) => {
  const bookmarksComponent = !isEmpty(bookmarks) ? (
    <Bookmarks data={{ ...bookmarks, controller, searchQuery }} />
  ) : null;
  return (
    <div className="search-bar input-group">
      <AutoComplete
        id={autocomplete.id}
        handleSearch={() => onSearch(searchQuery)}
        initialQuery={initialQuery || autocomplete.searchQuery || ''}
        useKeyShortcuts={autocomplete.useKeyShortcuts}
        url={autocomplete.url}
        controller={controller}
      />
      <div className="input-group-btn">
        <AutoComplete.SearchButton onClick={() => onSearch(searchQuery)} />
        {bookmarksComponent}
      </div>
    </div>
  );
};

SearchBar.propTypes = {
  searchQuery: PropTypes.string,
  initialQuery: PropTypes.string,
  onSearch: PropTypes.func,
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      results: PropTypes.array,
      searchQuery: PropTypes.string,
      url: PropTypes.string,
      useKeyShortcuts: PropTypes.bool,
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    }),
    controller: PropTypes.string,
    bookmarks: PropTypes.shape({ ...Bookmarks.propTypes }),
  }),
};

SearchBar.defaultProps = {
  searchQuery: '',
  initialQuery: '',
  onSearch: resolveSearchQuery,
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
