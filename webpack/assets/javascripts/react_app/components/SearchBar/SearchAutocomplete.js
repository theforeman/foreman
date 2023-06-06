import React, { useState, useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import { Menu, MenuContent, Popper, SearchInput } from '@patternfly/react-core';
import classNames from 'classnames';
import { AutoCompleteMenu } from './AutoCompleteMenu';
import { translate as __ } from '../../common/I18n';
import './SearchBar.scss';

export const SearchAutocomplete = ({
  results,
  onSearchChange,
  value,
  onSearch,
  disabled,
  error,
  name,
}) => {
  const [isAutocompleteOpen, setIsAutocompleteOpen] = useState(false);
  const searchWrapperRef = useRef(null);
  const searchInputRef = useRef(null);
  const autocompleteRef = useRef(null);

  const _onSearch = searchValue => {
    setIsAutocompleteOpen(false);
    onSearch && onSearch(searchValue);
  };
  const onClear = () => {
    onSearchChange('');
    _onSearch('');
  };

  const onChange = (newValue, e) => {
    if (searchInputRef?.current?.contains(document.activeElement)) {
      setIsAutocompleteOpen(true);
      onSearchChange(newValue);
    }
  };

  const onSelect = (e, itemId) => {
    e.stopPropagation();
    if (itemId[itemId.length - 1] !== ' ') {
      itemId = `${itemId} `;
    }
    if (itemId[0] === ' ') {
      itemId = itemId.slice(1);
    }
    onSearchChange(itemId);
    searchInputRef.current.focus();
  };

  useEffect(() => {
    const handleMenuKeys = event => {
      // keyboard shortcut to focus the search, will not focus if the key is typed into an input
      if (
        event.key === '/' &&
        event.target.tagName !== 'INPUT' &&
        event.target.tagName !== 'TEXTAREA'
      ) {
        event.preventDefault();
        searchInputRef.current.focus();
      }
      // if the autocomplete is open and the browser focus is on the search input,
      else if (isAutocompleteOpen && searchInputRef?.current === event.target) {
        // the escape key closes the autocomplete menu and keeps the focus on the search input.
        if (event.key === 'Escape') {
          setIsAutocompleteOpen(false);
          searchInputRef.current.focus();
          // the up and down arrow keys move browser focus into the autocomplete menu
        } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
          const firstElement = autocompleteRef.current.querySelector(
            'li > button:not(:disabled)'
          );
          firstElement && firstElement.focus();
          event.preventDefault(); // by default, the up and down arrow keys scroll the window
        } else if (
          autocompleteRef?.current?.contains(event.target) &&
          event.key === 'Tab'
        ) {
          event.preventDefault();
          setIsAutocompleteOpen(false);
          searchInputRef.current.focus();
        }
      }
    };
    // The autocomplete menu should close if the user clicks outside the menu.
    const handleClickOutside = event => {
      if (
        isAutocompleteOpen &&
        searchWrapperRef &&
        searchWrapperRef.current &&
        !searchWrapperRef.current.contains(event.target)
      ) {
        setIsAutocompleteOpen(false);
      }
    };
    window.addEventListener('keydown', handleMenuKeys);
    window.addEventListener('click', handleClickOutside);

    return () => {
      window.removeEventListener('keydown', handleMenuKeys);
      window.removeEventListener('click', handleClickOutside);
    };
  }, [isAutocompleteOpen]);
  const searchInput = (
    <div
      ref={searchWrapperRef}
      onClick={e => {
        if (e.target.type !== 'submit') setIsAutocompleteOpen(true);
      }}
      className={classNames('autocomplete-search', {
        'disabled-autocomplete-search': disabled,
      })}
    >
      <SearchInput
        ref={searchInputRef}
        value={value}
        onChange={onChange}
        onClear={onClear}
        onSearch={onSearch && _onSearch}
        isDisabled={disabled}
        placeholder={__('Search')}
        resetButtonLabel={__('Reset search')}
        name={name}
      />
    </div>
  );

  const autocomplete = (
    <Menu
      ouiaId="search-autocomplete-menu"
      ref={autocompleteRef}
      onSelect={error ? null : onSelect}
    >
      {!disabled && (
        <MenuContent>
          <AutoCompleteMenu results={results} error={error} />
        </MenuContent>
      )}
    </Menu>
  );

  return (
    <Popper
      trigger={searchInput}
      popper={autocomplete}
      isVisible={isAutocompleteOpen}
      enableFlip={false}
    />
  );
};

SearchAutocomplete.propTypes = {
  results: PropTypes.array.isRequired,
  onSearchChange: PropTypes.func.isRequired,
  value: PropTypes.string.isRequired,
  onSearch: PropTypes.func,
  disabled: PropTypes.bool,
  error: PropTypes.string,
  name: PropTypes.string,
};

SearchAutocomplete.defaultProps = {
  onSearch: null,
  disabled: false,
  error: null,
  name: null,
};
