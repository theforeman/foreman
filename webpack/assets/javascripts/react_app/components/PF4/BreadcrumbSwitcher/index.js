import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Popover,
  Button,
  Menu,
  SearchInput,
  Divider,
  MenuContent,
  MenuFooter,
  MenuList,
  MenuInput,
  MenuItem,
  Tooltip,
  Spinner,
} from '@patternfly/react-core';
import { ExchangeAltIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import Pagination from '../../Pagination';
import { removeLastSlashFromPath } from '../../../common/helpers';
import './breadcrumb-switcher.scss';

const BreadcrumbSwitcher = ({
  isOpen,
  isLoading,
  hasError,
  items,
  currentPage,
  total,
  openSwitcher,
  onHide,
  onOpen,
  onSearchChange,
  onSetPage,
  onPerPageSelect,
  perPage,
  searchValue,
  onSearchClear,
  searchDebounceTimeout,
  onResourceClick,
}) => {
  let menuListItems = [];
  const isActive = (href, id, name) => {
    const hrefWithName = href
      ? removeLastSlashFromPath(href.replace(id, name))
      : href;
    const getCurrentPath = () =>
      removeLastSlashFromPath(window.location.pathname);
    return (
      href === window.location.pathname || getCurrentPath() === hrefWithName
    );
  };

  if (isLoading) {
    menuListItems = (
      <MenuItem
        isDisabled
        key="loading"
        className="breadcrumb-switcher-spinner"
        aria-label="loading spinner"
      >
        <span>
          <Spinner />
        </span>
      </MenuItem>
    );
  } else if (hasError) {
    menuListItems = (
      <MenuItem isDisabled key="error">
        {__('An error occurred.')}
      </MenuItem>
    );
  } else if (items.length === 0) {
    menuListItems = (
      <MenuItem isDisabled key="no result">
        {__('No results found')}
      </MenuItem>
    );
  } else {
    menuListItems = items.map(({ href, id, name }) => (
      <MenuItem
        id={`${id}-${__(name)}`}
        key={id}
        itemId={id}
        to={href}
        onClick={e => onResourceClick(e, href)}
        className={
          isActive(href, id, name) ? 'breadcrumb-switcher-current-item' : ''
        }
      >
        <Tooltip content={__(name)}>
          <span>{__(name)}</span>
        </Tooltip>
      </MenuItem>
    ));
  }
  useEffect(() => {
    if (typingTimeout) {
      return () => clearTimeout(typingTimeout);
    }
    return undefined;
  }, [typingTimeout]);
  const [typingTimeout, setTypingTimeout] = useState(null);
  const autoSearch = searchTerm => {
    if (typingTimeout) clearTimeout(typingTimeout);
    setTypingTimeout(
      setTimeout(() => onSearchChange(searchTerm), searchDebounceTimeout)
    );
  };
  return (
    <div className="pf4-breadcrumb-switcher">
      <Popover
        className="pf4-breadcrumb-switcher-popover"
        isVisible={!!isOpen}
        shouldOpen={() => {
          openSwitcher();
          onOpen();
        }}
        shouldClose={onHide}
        hasNoPadding
        showClose={false}
        appendTo={() => document.querySelector('.pf4-breadcrumb-switcher')}
        position="bottom"
        bodyContent={
          <div>
            <Menu>
              <MenuInput>
                <SearchInput
                  value={searchValue}
                  aria-label="Filter breadcrumb items"
                  type="search"
                  onChange={value => {
                    autoSearch(value || '');
                  }}
                  onClear={onSearchClear}
                />
              </MenuInput>
              <Divider />
              <MenuContent>
                <MenuList>{menuListItems}</MenuList>
              </MenuContent>
              <MenuFooter>
                <Pagination
                  itemCount={total}
                  page={currentPage}
                  perPage={perPage}
                  onSetPage={onSetPage}
                  onPerPageSelect={onPerPageSelect}
                  updateParamsByUrl={false}
                  isCompact
                />
              </MenuFooter>
            </Menu>
          </div>
        }
      >
        <Button variant="plain" aria-label="open breadcrumb switcher">
          <ExchangeAltIcon />
        </Button>
      </Popover>
    </div>
  );
};

BreadcrumbSwitcher.propTypes = {
  onSearchChange: PropTypes.func.isRequired,
  onSetPage: PropTypes.func.isRequired,
  onPerPageSelect: PropTypes.func.isRequired,
  perPage: PropTypes.number.isRequired,
  hasError: PropTypes.bool.isRequired,
  onSearchClear: PropTypes.func.isRequired,
  onResourceClick: PropTypes.func.isRequired,
  items: PropTypes.array.isRequired,
  searchDebounceTimeout: PropTypes.number.isRequired,
  searchValue: PropTypes.string.isRequired,
  currentPage: PropTypes.number,
  total: PropTypes.number.isRequired,
  isOpen: PropTypes.bool.isRequired,
  isLoading: PropTypes.bool.isRequired,
  openSwitcher: PropTypes.func.isRequired,
  onOpen: PropTypes.func.isRequired,
  onHide: PropTypes.func.isRequired,
};

BreadcrumbSwitcher.defaultProps = {
  currentPage: 1,
};

export default BreadcrumbSwitcher;
