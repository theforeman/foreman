/* eslint-disable max-lines */

import React, { useEffect, useMemo, useRef, useState } from 'react';
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
  onBlur,
  allowClear,
}) => {
  if (validationStatus === 'error') validationStatus = 'danger';
  const NO_RESULTS = __('No matches found');
  const noOptions = useMemo(
    () => [
      { value: '', isAriaDisabled: true, disabled: true, label: NO_RESULTS },
    ],
    [NO_RESULTS]
  );

  const displayOptions = options.length < 1 ? noOptions : options;

  const displayValue =
    typeof selected === 'string' || typeof selected === 'number'
      ? displayOptions.find(o => o.value === selected)?.label || selected
      : selected?.label || selected || '';

  const [isOpen, setIsOpen] = useState(false);
  const [inputValue, setInputValue] = useState(displayValue);
  const [filterValue, setFilterValue] = useState('');
  const [selectOptions, setSelectOptions] = useState(displayOptions);
  const textInputRef = useRef(null);
  const inputValueRef = useRef(inputValue);

  useEffect(() => {
    setInputValue(displayValue);
    inputValueRef.current = displayValue;
  }, [displayValue]);

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
      setIsOpen(true);
    }
    setSelectOptions(newSelectOptions);
  }, [filterValue, displayOptions, NO_RESULTS, options]);

  const closeMenu = () => {
    setIsOpen(false);
  };

  const onClose = () => {
    closeMenu();
    setFilterValue('');
    if (
      allowClear &&
      !inputValueRef.current &&
      selected != null &&
      selected !== ''
    ) {
      onSelect('');
      onBlur('');
    } else {
      setInputValue(displayValue);
      inputValueRef.current = displayValue;
      onBlur(displayValue);
    }
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
    inputValueRef.current = String(content);
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
    inputValueRef.current = value;
    setFilterValue(value);
    if (allowClear && !value && selected != null && selected !== '') {
      onSelect('');
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
          inputId={fieldId ?? `id-${name}`}
          id={`typeahead-select-input-${name}`}
          innerRef={textInputRef}
          placeholder={placeholder}
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
    <div className="autocomplete-input-wrapper">
      <Select
        name={name}
        ouiaId={`autocomplete-select-${name}`}
        placeholder={placeholder}
        isOpen={isOpen}
        selected={selected}
        onSelect={onSelectLocal}
        onOpenChange={nextIsOpen => {
          if (!nextIsOpen) onClose();
          else setIsOpen(true);
        }}
        toggle={toggle}
        shouldFocusFirstItemOnOpen={false}
      >
        <SelectList id="select-typeahead-listbox">
          {selectOptions.map(option => (
            <SelectOption
              key={option.value || option.label}
              className={option.className}
              isDisabled={option.disabled || false}
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
  onBlur: PropTypes.func,
  allowClear: PropTypes.bool,
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
  onBlur: () => {},
  allowClear: true,
};

export default AutocompleteInputComponent;
