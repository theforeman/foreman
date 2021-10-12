import React from 'react';
import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import { Button } from '@patternfly/react-core';
import { SearchIcon } from '@patternfly/react-icons';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../PF4/Bookmarks';
import { changeQuery } from '../../common/urlHelpers';
import './search-bar.scss';

const SearchBar = props => {
  const {
    data: { autocomplete, controller, bookmarks },
    searchQuery,
    onSearch,
    initialQuery,
    onBookmarkClick,
  } = props;

  return (
    <div className="pf-c-search-input">
      <div className="search-bar pf-c-input-group" id="search-bar">
        <AutoComplete
          id={autocomplete.id}
          handleSearch={() => onSearch(searchQuery)}
          searchQuery={initialQuery || autocomplete.searchQuery || ''}
          useKeyShortcuts={autocomplete.useKeyShortcuts}
          url={autocomplete.url}
          controller={controller}
        />
        <Button
          id="btn-search"
          variant="control"
          aria-label="search button for search input"
          className="autocomplete-search-btn"
          onClick={() => onSearch(searchQuery)}
        >
          <SearchIcon />
        </Button>
        {!isEmpty(bookmarks) && (
          <Bookmarks
            onBookmarkClick={onBookmarkClick}
            controller={controller}
            searchQuery={searchQuery}
            {...bookmarks}
          />
        )}
      </div>
    </div>
  );
};

SearchBar.propTypes = {
  searchQuery: PropTypes.string,
  initialQuery: PropTypes.string,
  onSearch: PropTypes.func,
  onBookmarkClick: PropTypes.func,
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      results: PropTypes.array,
      searchQuery: PropTypes.string,
      url: PropTypes.string,
      useKeyShortcuts: PropTypes.bool,
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    }),
    controller: PropTypes.string,
    bookmarks: PropTypes.object,
  }),
};

SearchBar.defaultProps = {
  searchQuery: '',
  initialQuery: '',
  onSearch: searchQuery => changeQuery({ search: searchQuery.trim(), page: 1 }),
  onBookmarkClick: searchQuery =>
    changeQuery({ search: searchQuery.trim(), page: 1 }),
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
