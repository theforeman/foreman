import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import {
  Spinner,
  Button,
  ListGroup,
  ListGroupItem,
  TypeAheadSelect,
} from 'patternfly-react';
import { createItemProps } from './SelectHelper';
import { noop } from '../../common/helpers';
import SelectInput from './SelectInput';
import './select.scss';

const Select = ({
  disabled,
  emptyText,
  focusOnMount,
  isLoading,
  isSearchable,
  loadingText,
  onItemClick,
  onKeyDown,
  onSearchChange,
  onSearchClear,
  onToggle,
  open,
  options,
  placeholder,
  searchValue,
  selectedItem,
}) => {
  const classes = classNames('select-container-pf', { open });

  const renderResults = results =>
    results.length === 0 ? (
      <ListGroupItem
        id="select-empty"
        key="empty"
        className="select-empty-list"
      >
        <span id="empty-text">{emptyText}</span>
      </ListGroupItem>
    ) : (
      results.map((opt, i) => (
        <ListGroupItem
          {...createItemProps(
            opt,
            selectedItem,
            opt.className || 'no-border',
            onItemClick
          )}
        >
          <EllipsisWithTooltip>
            {searchValue && searchValue.length ? (
              <TypeAheadSelect.Highlighter search={searchValue}>
                {opt.name}
              </TypeAheadSelect.Highlighter>
            ) : (
              opt.name
            )}
          </EllipsisWithTooltip>
        </ListGroupItem>
      ))
    );

  return (
    <div className={classes}>
      <Button
        disabled={disabled}
        onClick={onToggle}
        active={open}
        className="select-dropdown-toggle"
      >
        {selectedItem.id ? (
          <EllipsisWithTooltip>{selectedItem.name}</EllipsisWithTooltip>
        ) : (
          <EllipsisWithTooltip>
            <span className="select-toggle-placeholder">{placeholder}</span>
          </EllipsisWithTooltip>
        )}
        <span className="caret select-caret" />
      </Button>
      {open && (
        <div className="select-body-container">
          {isSearchable && (
            <SelectInput
              onClear={onSearchClear}
              focus={focusOnMount}
              onChange={onSearchChange}
              onKeyDown={onKeyDown}
              placeholder={placeholder}
              searchValue={searchValue}
            />
          )}
          <ListGroup className="select-scrollable-list">
            {isLoading ? (
              <ListGroupItem
                id="select-loading"
                key="loading"
                className="select-loading-list"
              >
                <div id="select-loading-container">
                  <Spinner id="select-spinner" loading size="sm" />{' '}
                  <span>{loadingText}</span>
                </div>
              </ListGroupItem>
            ) : (
              renderResults(options)
            )}
          </ListGroup>
        </div>
      )}
    </div>
  );
};

Select.propTypes = {
  /** is Select disabled */
  disabled: PropTypes.bool,

  /** no Results text */
  emptyText: PropTypes.string,

  /** should Search input take focus on open */
  focusOnMount: PropTypes.bool,

  /** isLoading bool */
  isLoading: PropTypes.bool,

  /** show Search bool */
  isSearchable: PropTypes.bool,

  /** isLoading text */
  loadingText: PropTypes.string,

  /** onItemClick func({ event, id, name }) */
  onItemClick: PropTypes.func,

  /** onKeyDown func(event) */
  onKeyDown: PropTypes.func,

  /** onSearchChange func(event) */
  onSearchChange: PropTypes.func,

  /** onSearchClear func() */
  onSearchClear: PropTypes.func,

  /** onToggle func() */
  onToggle: PropTypes.func,

  /** isOpen bool */
  open: PropTypes.bool.isRequired,

  /** options array */
  options: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
      name: PropTypes.string,
    })
  ).isRequired,

  /** placeholder */
  placeholder: PropTypes.string,

  /** searchValue */
  searchValue: PropTypes.string,

  /** selectedItem object { id: string, name: string } */
  selectedItem: PropTypes.PropTypes.shape({
    id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
    name: PropTypes.string,
  }),
};

Select.defaultProps = {
  disabled: false,
  emptyText: 'No Results',
  focusOnMount: true,
  isLoading: false,
  isSearchable: true,
  loadingText: 'Loading...',
  onItemClick: noop,
  onKeyDown: noop,
  onSearchChange: noop,
  onSearchClear: noop,
  onToggle: noop,
  placeholder: 'Filter...',
  searchValue: '',
  selectedItem: {
    id: 'null',
    name: 'null',
  },
};

export default Select;
