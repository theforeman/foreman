import React from 'react';
import isEmpty from 'lodash/isEmpty';
import PropTypes from 'prop-types';
import URI from 'urijs';
import classNames from 'classnames';
import AutoComplete from '../AutoComplete';
import Bookmarks from '../bookmarks';
import { noop } from '../../common/helpers';
import './search-bar.scss';

const handleSearch = (searchQuery, onSearch) => {
  onSearch(searchQuery);
  const uri = new URI(window.location.href);
  const data = { ...uri.query(true), search: searchQuery.trim(), page: 1 };
  uri.query(URI.buildQuery(data, true));
  window.Turbolinks.visit(uri.toString());
};

const SearchBar = ({
  className,
  searchQuery,
  onSearch,
  autocomplete,
  controller,
  bookmarks,
}) => (
  <div className={classNames('search-bar', 'input-group', className)}>
    <AutoComplete
      id={autocomplete.id}
      controller={controller}
      handleSearch={() => handleSearch(searchQuery, onSearch)}
      initialQuery={autocomplete.searchQuery || ''}
      useKeyShortcuts={autocomplete.useKeyShortcuts}
      initialUrl={autocomplete.url}
      initialDisabled={autocomplete.isDisabled}
    />
    <div className="input-group-btn">
      <AutoComplete.SearchButton
        onClick={() => handleSearch(searchQuery, onSearch)}
      />
      {!isEmpty(bookmarks) ? (
        <Bookmarks data={{ ...bookmarks, controller, searchQuery }} />
      ) : null}
    </div>
  </div>
);

SearchBar.propTypes = {
  className: PropTypes.string,
  searchQuery: PropTypes.string,
  onSearch: PropTypes.func,
  autocomplete: PropTypes.shape({
    searchQuery: PropTypes.string,
    url: PropTypes.string,
    useKeyShortcuts: PropTypes.bool,
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
    isDisabled: PropTypes.bool,
  }),
  controller: PropTypes.string,
  bookmarks: PropTypes.shape({ ...Bookmarks.propTypes }),
};

SearchBar.defaultProps = {
  className: null,
  searchQuery: '',
  onSearch: noop,
  autocomplete: {
    results: [],
    searchQuery: null,
    url: null,
    useKeyShortcuts: true,
    isDisabled: false,
  },
  controller: null,
  bookmarks: {},
};

export default SearchBar;
