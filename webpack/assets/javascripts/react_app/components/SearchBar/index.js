import React, { useState } from 'react';
import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import { SearchAutocomplete } from './SearchAutocomplete';
import { useAPI } from '../../common/hooks/API/APIHooks';
import Bookmarks from '../PF4/Bookmarks';
import { changeQuery } from '../../common/urlHelpers';
import { STATUS } from '../../constants';
import { noop } from '../../common/helpers';

const SearchBar = ({
  data: {
    autocomplete: { url, searchQuery, apiParams } = { url: '' },
    controller,
    bookmarks,
    disabled,
  },
  initialQuery,
  restrictedSearchQuery,
  onSearch,
  onSearchChange,
  name,
  bookmarksPosition,
}) => {
  const [search, setSearch] = useState(initialQuery || searchQuery || '');
  const { response, status, setAPIOptions } = useAPI('get', url, {
    params: { ...apiParams, search },
  });
  const [prevSearch, setPrevSearch] = useState(searchQuery);
  if (searchQuery !== prevSearch) {
    setPrevSearch(searchQuery);
    if (searchQuery !== search) {
      setSearch(restrictedSearchQuery(searchQuery) ?? (searchQuery || ''));
      setAPIOptions({
        params: {
          ...apiParams,
          search: restrictedSearchQuery(searchQuery) ?? (searchQuery || ''),
        },
      });
    }
  }
  const _onSearchChange = newValue => {
    onSearchChange(newValue);
    setSearch(newValue);
    setAPIOptions({ params: { ...apiParams, search: newValue } });
  };
  const _onSearch = searchValue => {
    if (restrictedSearchQuery(searchValue)) {
      return onSearch(restrictedSearchQuery(searchValue));
    }
    return onSearch(searchValue);
  };
  const error =
    status === STATUS.ERROR || response?.[0]?.error
      ? response?.[0]?.error || response.message
      : null;
  return (
    <div className="foreman-search-bar">
      <SearchAutocomplete
        results={
          Array.isArray(response) && !response?.[0]?.error ? response : []
        }
        onSearchChange={_onSearchChange}
        value={search}
        onSearch={onSearch && _onSearch}
        disabled={disabled}
        error={error}
        name={name}
      />
      {!isEmpty(bookmarks) && (
        <Bookmarks
          onBookmarkClick={newSearch => {
            _onSearchChange(newSearch);
            if (onSearch) onSearch(newSearch);
          }}
          controller={controller}
          searchQuery={search || ''}
          bookmarksPosition={bookmarksPosition}
          {...bookmarks}
        />
      )}
    </div>
  );
};

SearchBar.propTypes = {
  data: PropTypes.shape({
    autocomplete: PropTypes.shape({
      url: PropTypes.string.isRequired,
      searchQuery: PropTypes.string,
    }).isRequired,
    controller: PropTypes.string,
    bookmarks: PropTypes.shape({
      id: PropTypes.string,
      url: PropTypes.string,
      canCreate: PropTypes.bool,
      documentationUrl: PropTypes.string,
    }),
    disabled: PropTypes.bool,
  }).isRequired,
  initialQuery: PropTypes.string,
  onSearch: PropTypes.func,
  restrictedSearchQuery: PropTypes.func,
  onSearchChange: PropTypes.func,
  name: PropTypes.string,
  bookmarksPosition: PropTypes.string,
};

SearchBar.defaultProps = {
  initialQuery: '',
  onSearch: searchQuery => changeQuery({ search: searchQuery.trim(), page: 1 }),
  onSearchChange: noop,
  restrictedSearchQuery: noop,
  name: null,
  bookmarksPosition: 'left',
};

export default SearchBar;
