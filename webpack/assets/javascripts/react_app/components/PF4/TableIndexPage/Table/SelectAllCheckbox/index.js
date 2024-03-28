import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown,
  DropdownToggle,
  DropdownToggleCheckbox,
  DropdownItem,
} from '@patternfly/react-core';
import { translate as __ } from '../../../../../common/I18n';
import { noop } from '../../../../../common/helpers';

import './SelectAllCheckbox.scss';

const SelectAllCheckbox = ({
  selectNone,
  selectDefault,
  selectPage,
  selectedCount,
  selectedDefaultCount,
  pageRowCount,
  totalCount,
  areAllRowsOnPageSelected,
  areAllRowsSelected,
  selectAll,
}) => {
  const [isSelectAllDropdownOpen, setSelectAllDropdownOpen] = useState(false);
  const [selectionToggle, setSelectionToggle] = useState(false);

  const canSelectAll = selectAll !== noop;
  // Checkbox states: false = unchecked, null = partially-checked, true = checked
  // Flow: All are selected -> click -> none are selected
  // Some are selected -> click -> none are selected
  // None are selected -> click -> all are selected, or page is selected (depends on canSelectAll)
  const onSelectAllCheckboxChange = checked => {
    if (checked && selectionToggle !== null) {
      if (!canSelectAll) {
        selectPage();
      } else {
        selectAll(true);
      }
    } else if (selectDefault === null) {
      selectNone();
    } else {
      selectDefault();
    }
  };

  const onSelectAllDropdownToggle = () =>
    setSelectAllDropdownOpen(isOpen => !isOpen);

  const handleSelectAll = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(true);
    selectAll(true);
  };
  const handleSelectPage = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(true);
    selectPage();
  };
  const handleSelectNone = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(false);
    selectNone();
  };
  const handleSelectDefault = () => {
    setSelectAllDropdownOpen(false);
    setSelectionToggle(false);
    selectDefault();
  };

  useEffect(() => {
    let newCheckedState = null; // null is partially-checked state

    if (areAllRowsSelected) {
      newCheckedState = true;
    } else if (selectedCount === 0) {
      newCheckedState = false;
    }
    setSelectionToggle(newCheckedState);
  }, [selectedCount, areAllRowsSelected]);

  const selectAllDropdownItems = [
    <DropdownItem
      key="select-page"
      ouiaId="select-page"
      component="button"
      isDisabled={pageRowCount === 0 || areAllRowsOnPageSelected}
      onClick={handleSelectPage}
    >
      {`${__('Select page')} (${pageRowCount})`}
    </DropdownItem>,
  ];
  if (selectDefault === null) {
    selectAllDropdownItems.unshift(
      <DropdownItem
        key="select-none"
        ouiaId="select-none"
        component="button"
        isDisabled={selectedCount === 0}
        onClick={handleSelectNone}
      >
        {`${__('Select none')} (0)`}
      </DropdownItem>
    );
  } else {
    selectAllDropdownItems.unshift(
      <DropdownItem
        key="select-default"
        ouiaId="select-default"
        component="button"
        isDisabled={totalCount === 0}
        onClick={handleSelectDefault}
      >
        {`${__('Select default')} (${selectedDefaultCount})`}
      </DropdownItem>
    );
  }
  if (canSelectAll) {
    selectAllDropdownItems.push(
      <DropdownItem
        key="select-all"
        id="all"
        ouiaId="select-all"
        component="button"
        isDisabled={totalCount === 0 || areAllRowsSelected}
        onClick={handleSelectAll}
      >
        {`${__('Select all')} (${totalCount})`}
      </DropdownItem>
    );
  }

  return (
    <Dropdown
      toggle={
        <DropdownToggle
          onToggle={onSelectAllDropdownToggle}
          id="select-all-checkbox-dropdown-toggle"
          ouiaId="select-all-checkbox-dropdown-toggle"
          splitButtonItems={[
            <DropdownToggleCheckbox
              className="table-select-all-checkbox"
              key="table-select-all-checkbox"
              ouiaId="select-all-checkbox-dropdown-toggle-checkbox"
              aria-label="Select all"
              onChange={checked => onSelectAllCheckboxChange(checked)}
              isChecked={selectionToggle}
              isDisabled={totalCount === 0 && selectedCount === 0}
            >
              {selectedCount > 0 && `${selectedCount} selected`}
            </DropdownToggleCheckbox>,
          ]}
        />
      }
      isOpen={isSelectAllDropdownOpen}
      dropdownItems={selectAllDropdownItems}
      id="selection-checkbox"
      ouiaId="selection-checkbox"
    />
  );
};

SelectAllCheckbox.propTypes = {
  selectedCount: PropTypes.number.isRequired,
  selectNone: PropTypes.func.isRequired,
  selectPage: PropTypes.func.isRequired,
  selectAll: PropTypes.func,
  selectDefault: PropTypes.func,
  selectedDefaultCount: PropTypes.number,
  pageRowCount: PropTypes.number,
  totalCount: PropTypes.number,
  areAllRowsOnPageSelected: PropTypes.bool.isRequired,
  areAllRowsSelected: PropTypes.bool.isRequired,
};

SelectAllCheckbox.defaultProps = {
  selectAll: noop,
  selectDefault: null,
  pageRowCount: 0,
  totalCount: 0,
  selectedDefaultCount: 0,
};

export default SelectAllCheckbox;
