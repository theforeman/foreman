import React, { useState, useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Menu,
  MenuContent,
  MenuItem,
  MenuList,
  Popper,
  SearchInput,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

export const NavigationSearch = ({ items, clickAndNavigate }) => {
  let parent = null;
  const navLinksArray = [];
  items.forEach(item => {
    item.subItems.forEach(group => {
      if (group.isDivider) {
        parent = group.title;
      } else {
        navLinksArray.push({
          ...group,
          parents: [item.title, parent].filter(Boolean),
        });
      }
    });
    parent = null;
  });

  const navItems = navLinksArray.map(item => item.title);
  const menuNav = ({ id, title, href, onClick, parents }, key) => (
    <MenuItem
      to={href}
      onClick={event => clickAndNavigate(onClick, href, event)}
      itemId={`${id}_${key}`}
      key={`${id}_${key}`}
      description={[...parents, title].join(' > ')}
    >
      {title}
    </MenuItem>
  );
  const [autocompleteOptions, setAutocompleteOptions] = useState(
    navLinksArray.slice(0, 10).map(menuNav)
  );
  const [value, setValue] = useState('');

  const [isAutocompleteOpen, setIsAutocompleteOpen] = useState(false);

  const searchInputRef = useRef(null);
  const autocompleteRef = useRef(null);

  const onClear = () => {
    setValue('');
    setAutocompleteOptions(navLinksArray.slice(0, 10).map(menuNav));
  };

  const onChange = newValue => {
    // When the value of the search input changes, build a list of no more than 10 autocomplete options.
    let options = navLinksArray
      .filter(({ title }) =>
        title.toLowerCase().includes(newValue.toLowerCase())
      )
      .map(menuNav);
    if (options.length > 10) {
      options = options.slice(0, 10);
    }

    setAutocompleteOptions(options);
    if (
      newValue !== '' &&
      searchInputRef?.current?.contains(document.activeElement)
    ) {
      // The menu is hidden if there are no options
      setIsAutocompleteOpen(options.length > 0);
    } else {
      setIsAutocompleteOpen(false);
    }
    setValue(newValue);
  };
  // Whenever an autocomplete option is selected, set the search input value, close the menu, and put the browser
  // focus back on the search input
  const onSelect = e => {
    e.stopPropagation();
    setIsAutocompleteOpen(false);
  };

  useEffect(() => {
    const handleClick = event => {
      if (
        isAutocompleteOpen &&
        autocompleteRef?.current &&
        !autocompleteRef.current.contains(event.target)
      ) {
        // The autocomplete menu should close if the user clicks outside the menu.
        setIsAutocompleteOpen(false);
      } else if (
        !isAutocompleteOpen &&
        searchInputRef?.current &&
        searchInputRef.current.contains(event.target)
      ) {
        // The autocomplete menu should open if the user clicks on the search input.
        setIsAutocompleteOpen(true);
      }
    };
    const handleMenuKeys = event => {
      if (
        isAutocompleteOpen &&
        searchInputRef.current &&
        searchInputRef.current === event.target
      ) {
        // the escape key closes the autocomplete menu and keeps the focus on the search input.
        if (event.key === 'Escape') {
          setIsAutocompleteOpen(false);
          searchInputRef.current.focus();
          // the up and down arrow keys move browser focus into the autocomplete menu
        } else if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
          const firstElement = autocompleteRef.current.querySelector(
            'li > a:not(:disabled)'
          );
          firstElement && firstElement.focus();
          event.preventDefault(); // by default, the up and down arrow keys scroll the window
          // the tab, enter, and space keys will close the menu, and the tab key will move browser
          // focus forward one element (by default)
        } else if (
          event.key === 'Tab' ||
          event.key === 'Enter' ||
          event.key === 'Space'
        ) {
          setIsAutocompleteOpen(false);
          if (event.key === 'Enter' || event.key === 'Space') {
            event.preventDefault();
          }
        }
        // If the autocomplete is open and the browser focus is in the autocomplete menu
        // hitting tab will close the autocomplete and but browser focus back on the search input.
      } else if (
        isAutocompleteOpen &&
        autocompleteRef?.current?.contains(event.target) &&
        event.key === 'Tab'
      ) {
        event.preventDefault();
        setIsAutocompleteOpen(false);
        searchInputRef.current.focus();
      }
    };
    window.addEventListener('keydown', handleMenuKeys);
    window.addEventListener('click', handleClick);
    return () => {
      window.removeEventListener('keydown', handleMenuKeys);
      window.removeEventListener('click', handleClick);
    };
  }, [isAutocompleteOpen]);
  useEffect(() => {
    const handleKeyDown = event => {
      if (event.ctrlKey && event.shiftKey && event.key === 'F') {
        // Focus the search input on Ctrl+Shift+F
        if (searchInputRef.current) {
          searchInputRef.current.focus();
        }
      }
    };

    // Add the event listener
    window.addEventListener('keydown', handleKeyDown);

    // Remove the event listener when the component unmounts
    return () => {
      window.removeEventListener('keydown', handleKeyDown);
    };
  }, []);

  const searchInput = (
    <SearchInput
      value={value}
      placeholder={__('Search and go')}
      onChange={onChange}
      onClear={onClear}
      ref={searchInputRef}
      id="navigation-search"
      onSearch={(_, event) => {
        const firstItem = navItems.find(option =>
          option.toLowerCase().includes(value.toLowerCase())
        );
        if (firstItem) {
          const navLink = navLinksArray.find(
            ({ title }) => title === firstItem
          );
          clickAndNavigate(navLink.onClick, navLink.href, event);
        }
      }}
    />
  );

  const autocomplete = (
    <Menu
      ouiaId="navigation-search-menu"
      ref={autocompleteRef}
      onSelect={onSelect}
      className="navigation-search-menu"
    >
      <MenuContent>
        <MenuList>{autocompleteOptions}</MenuList>
      </MenuContent>
    </Menu>
  );

  return (
    <Popper
      trigger={searchInput}
      popper={autocomplete}
      isVisible={isAutocompleteOpen}
      enableFlip={false}
      // append the autocomplete menu to the search input in the DOM for the sake of the keyboard navigation experience
      appendTo={() => document.querySelector('#navigation-search')}
    />
  );
};

NavigationSearch.propTypes = {
  items: PropTypes.array.isRequired,
  clickAndNavigate: PropTypes.func.isRequired,
};
