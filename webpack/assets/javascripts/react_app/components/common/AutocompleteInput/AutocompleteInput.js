/* eslint-disable max-lines */

import React, { useEffect, useRef, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Select,
  SelectOption,
  SelectList,
  MenuToggle,
  TextInputGroup,
  TextInputGroupMain,
  TextInputGroupUtilities,
  HelperTextItem,
  HelperText,
} from '@patternfly/react-core';
import { sprintf, translate as __ } from 'foremanReact/common/I18n';

const DEFAULT_PLACEHOLDER = __('Start typing to search');
export const AutocompleteInputComponent = ({
  selected,
  onSelect,
  onChange,
  options,
  name,
  placeholder,
  validationStatus,
  validationMsg,
  isDisabled,
  fieldId,
}) => {
  if (validationStatus === 'error') validationStatus = 'danger';
  const NO_RESULTS = __('No matches found');
  const noOptions = [
    { value: '', isAriaDisabled: true, disabled: true, label: NO_RESULTS },
  ];

  const displayOptions = options.length < 1 ? noOptions : options;

  const displayValue =
    typeof selected === 'string' || typeof selected === 'number'
      ? displayOptions.find(o => o.value === selected)?.label || selected
      : selected?.label || selected || '';

  const [isOpen, setIsOpen] = useState(false);
  const [inputValue, setInputValue] = useState(displayValue);
  const [filterValue, setFilterValue] = useState('');
  const [selectOptions, setSelectOptions] = useState(displayOptions);
  const [focusedItemIndex, setFocusedItemIndex] = useState(null);
  const [activeItemId, setActiveItemId] = useState(null);
  const textInputRef = useRef(null);
  const wrapperRef = useRef(null);

  useEffect(() => {
    const input = textInputRef.current;
    if (!input) return;
    input.setAttribute('autocomplete', 'off');
  }, []);

  useEffect(() => {
    let newSelectOptions = displayOptions;
    if (filterValue) {
      newSelectOptions = displayOptions.filter(menuItem =>
        String(menuItem.label)
          .toLowerCase()
          .includes(filterValue.toLowerCase())
      );
      if (!newSelectOptions.length) {
        newSelectOptions = [
          {
            isAriaDisabled: true,
            label: sprintf(__('No results found for %s'), filterValue),
            value: NO_RESULTS,
          },
        ];
      }
      if (!isOpen) {
        setIsOpen(true);
      }
    }
    setSelectOptions(newSelectOptions);

    /* eslint-disable react-hooks/exhaustive-deps */
  }, [filterValue]);

  const createItemId = value => `select-typeahead-${value}`;
  const setActiveAndFocusedItem = itemIndex => {
    setFocusedItemIndex(itemIndex);
    const focusedItem = selectOptions[itemIndex];
    setActiveItemId(createItemId(focusedItem.value));
  };
  const resetActiveAndFocusedItem = () => {
    setFocusedItemIndex(null);
    setActiveItemId(null);
  };
  const closeMenu = () => {
    setIsOpen(false);
    resetActiveAndFocusedItem();
  };

  const handleBlurCapture = e => {
    const next = e.relatedTarget;
    if (!wrapperRef.current?.contains(next)) {
      closeMenu();
    }
    setInputValue(displayValue);
  };

  const onInputClick = () => {
    if (!isOpen) {
      setIsOpen(true);
    } else if (!inputValue) {
      closeMenu();
    }
  };
  const selectOption = (value, content) => {
    setInputValue(String(content));
    setFilterValue('');
    onSelect(value);
    closeMenu();
  };
  const onSelectLocal = (_event, value) => {
    if (value && value !== NO_RESULTS) {
      const optionText = selectOptions.find(option => option.value === value)
        ?.label;
      selectOption(value, optionText);
    }
  };
  const onTextInputChange = (_event, value) => {
    onChange(value);
    setInputValue(value);
    setFilterValue(value);
    resetActiveAndFocusedItem();
  };
  const handleMenuArrowKeys = key => {
    let indexToFocus = 0;
    if (!isOpen) {
      setIsOpen(true);
    }
    if (selectOptions.every(option => option.isDisabled)) {
      return;
    }
    if (key === 'ArrowUp') {
      if (focusedItemIndex === null || focusedItemIndex === 0) {
        indexToFocus = selectOptions.length - 1;
      } else {
        indexToFocus = focusedItemIndex - 1;
      }
      while (selectOptions[indexToFocus].isDisabled) {
        indexToFocus--;
        if (indexToFocus === -1) {
          indexToFocus = selectOptions.length - 1;
        }
      }
    }
    if (key === 'ArrowDown') {
      if (
        focusedItemIndex === null ||
        focusedItemIndex === selectOptions.length - 1
      ) {
        indexToFocus = 0;
      } else {
        indexToFocus = focusedItemIndex + 1;
      }
      while (selectOptions[indexToFocus].isDisabled) {
        indexToFocus++;
        if (indexToFocus === selectOptions.length) {
          indexToFocus = 0;
        }
      }
    }
    setActiveAndFocusedItem(indexToFocus);
  };
  const onInputKeyDown = event => {
    const focusedItem =
      focusedItemIndex !== null ? selectOptions[focusedItemIndex] : null;
    // eslint-disable-next-line default-case
    switch (event.key) {
      case 'Enter':
        if (
          isOpen &&
          focusedItem &&
          focusedItem.value !== NO_RESULTS &&
          !focusedItem.isAriaDisabled
        ) {
          selectOption(focusedItem.value, focusedItem.label);
        }
        if (!isOpen) {
          setIsOpen(true);
        }
        break;
      case 'ArrowUp':
      case 'ArrowDown':
        event.preventDefault();
        handleMenuArrowKeys(event.key);
        break;
    }
  };
  const onToggleClick = () => {
    setIsOpen(!isOpen);
    // eslint-disable-next-line no-unused-expressions
    textInputRef?.current?.focus();
  };

  const toggle = toggleRef => (
    <MenuToggle
      ref={toggleRef}
      variant="typeahead"
      aria-label="Typeahead menu toggle"
      onClick={onToggleClick}
      isExpanded={isOpen}
      isDisabled={isDisabled}
      isFullWidth
      status={validationStatus}
    >
      <TextInputGroup isPlain>
        <TextInputGroupMain
          name={name}
          value={inputValue}
          onClick={onInputClick}
          onChange={onTextInputChange}
          onKeyDown={onInputKeyDown}
          inputId={fieldId ?? `id-${name}`}
          id={`typeahead-select-input-${name}`}
          innerRef={textInputRef}
          placeholder={placeholder}
          {...(activeItemId && {
            'aria-activedescendant': activeItemId,
          })}
          role="combobox"
          isExpanded={isOpen}
          aria-controls={`id-${name}`}
        />

        <TextInputGroupUtilities
          {...(!inputValue
            ? {
                style: {
                  display: 'none',
                },
              }
            : {})}
        />
      </TextInputGroup>
    </MenuToggle>
  );
  return (
    <div
      ref={wrapperRef}
      onBlurCapture={handleBlurCapture}
      className="autocomplete-input-wrapper"
    >
      <Select
        name={name}
        ouiaId={`autocomplete-select-${name}`}
        placeholder={placeholder}
        isOpen={isOpen}
        selected={selected}
        onSelect={onSelectLocal}
        onOpenChange={nextIsOpen => {
          if (!nextIsOpen) closeMenu();
          else setIsOpen(true);
        }}
        toggle={toggle}
        shouldFocusFirstItemOnOpen={false}
      >
        <SelectList id="select-typeahead-listbox">
          {selectOptions.map((option, index) => (
            <SelectOption
              key={option.value || option.label}
              isFocused={focusedItemIndex === index}
              className={option.className}
              isDisabled={option.disabled || false}
              id={createItemId(option.value)}
              {...option}
              ref={null}
            >
              {option.label}
            </SelectOption>
          ))}
        </SelectList>
      </Select>
      {validationStatus !== undefined && (
        <HelperText isLiveRegion>
          <HelperTextItem variant={validationStatus}>
            {validationMsg}
          </HelperTextItem>
        </HelperText>
      )}
    </div>
  );
};

AutocompleteInputComponent.propTypes = {
  selected: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.number,
    PropTypes.bool,
  ]),
  onSelect: PropTypes.func,
  onChange: PropTypes.func,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
        .isRequired,
      label: PropTypes.string.isRequired,
    })
  ),
  name: PropTypes.string.isRequired,
  placeholder: PropTypes.string,
  validationStatus: PropTypes.string,
  validationMsg: PropTypes.string,
  isDisabled: PropTypes.bool,
  fieldId: PropTypes.string,
};

AutocompleteInputComponent.defaultProps = {
  options: [],
  selected: undefined,
  placeholder: DEFAULT_PLACEHOLDER,
  validationStatus: undefined,
  validationMsg: null,
  onSelect: () => {},
  onChange: () => {},
  isDisabled: false,
  fieldId: undefined,
};

export default AutocompleteInputComponent;
