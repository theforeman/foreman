import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import EllipsisWithTooltip from 'react-ellipsis-with-tooltip';
import { isEmpty } from 'lodash';
import {
  Spinner,
  Button,
  ListGroup,
  ListGroupItem,
  TypeAheadSelect,
} from 'patternfly-react';
import { noop } from '../../common/helpers';
import SelectInput from './SelectInput';
import './select.scss';

const Select = ({
  cursor,
  emptyText,
  isLoading,
  loadingText,
  onChange,
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
  const classes = classNames('select-container', { open });
  const itemClasses = (itemclasses, cur) =>
    classNames(itemclasses, { cursor: cur });

  const createItemProps = (
    { id, name, className = 'no-border', disabled = false },
    i
  ) => {
    const key = `${id}-${name}`;
    const itemProps = {
      key,
      id: key,
      className: itemClasses(className, cursor === i),
      active: selectedItem.id === id,
    };

    if (disabled) return { ...itemProps, disabled: true };
    return { ...itemProps, onClick: e => onChange({ e, id, name }) };
  };

  const renderResults = results =>
    isEmpty(results) ? (
      <ListGroupItem
        id="select-empty"
        key="empty"
        className="select-empty-list"
      >
        <span id="empty-text">{emptyText}</span>
      </ListGroupItem>
    ) : (
      results.map((opt, i) => (
        <ListGroupItem {...createItemProps(opt, i)}>
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
          <SelectInput
            onClear={onSearchClear}
            focus
            onSearchChange={onSearchChange}
            onKeyDown={onKeyDown}
            placeholder={placeholder}
            searchValue={searchValue}
          />
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
  /** cursor position for keyboard navigation */
  cursor: PropTypes.number,

  /** no Results text */
  emptyText: PropTypes.string,

  /** isLoading bool */
  isLoading: PropTypes.bool,

  /** isLoading text */
  loadingText: PropTypes.string,

  /** onChange func({ event, id, name }) */
  onChange: PropTypes.func,

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
      id: PropTypes.string,
      name: PropTypes.string,
    })
  ).isRequired,

  /** placeholder */
  placeholder: PropTypes.string,

  /** searchValue */
  searchValue: PropTypes.string,

  /** selectedItem object { id: string, name: string } */
  selectedItem: PropTypes.PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
  }),
};

Select.defaultProps = {
  cursor: -1,
  emptyText: 'No Results',
  isLoading: false,
  loadingText: 'Loading...',
  onChange: noop,
  onKeyDown: noop,
  onSearchChange: noop,
  onSearchClear: noop,
  onToggle: noop,
  placeholder: 'Filter...',
  searchValue: '',
  selectedItem: {
    id: '10',
    name: 'ten',
  },
};

export default Select;
