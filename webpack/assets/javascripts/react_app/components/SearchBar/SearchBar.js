import React from 'react';
import isEmpty from 'lodash/isEmpty';
import PropTypes from 'prop-types';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../bookmarks';
import { resolveSearchQuery } from './SearchBarHelpers';
import './search-bar.scss';

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
        handleSearch={() => resolveSearchQuery(searchQuery)}
        initialQuery={autocomplete.searchQuery || ''}
        useKeyShortcuts={autocomplete.useKeyShortcuts}
        url={autocomplete.url}
        controller={controller}
      />
      <div className="input-group-btn">
        <AutoComplete.SearchButton
          onClick={() => resolveSearchQuery(searchQuery)}
        />
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
