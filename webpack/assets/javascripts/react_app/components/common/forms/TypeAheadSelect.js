import React from 'react';
import PropTypes from 'prop-types';

import {
  Select,
  SelectOption,
  SelectList,
  MenuToggle,
  TextInputGroup,
  TextInputGroupMain,
  TextInputGroupUtilities,
  Button,
} from '@patternfly/react-core';
import TimesIcon from '@patternfly/react-icons/dist/esm/icons/times-icon';

const TypeAheadSelect = ({
  placeholder,
  options,
  onChange,
  selectedItem = [],
}) => {
  const initState = (selectedItem || [{ value: '', label: '' }])[0];
  const [isOpen, setIsOpen] = React.useState(false);
  const [selected, setSelected] = React.useState(initState.value);
  const [inputText, setInputText] = React.useState(initState.label);
  const [filterValue, setFilterValue] = React.useState('');
  const [selectOptions, setSelectOptions] = React.useState(options);
  const [focusedItemIndex, setFocusedItemIndex] = React.useState(null);
  const [activeItemId, setActiveItemId] = React.useState(null);
  const textInputRef = React.useRef();
  const NO_RESULTS = 'no results';

  React.useEffect(() => {
    let newSelectOptions = options;
    if (filterValue) {
      newSelectOptions = options.filter(menuItem =>
        String(menuItem.value)
          .toLowerCase()
          .includes(filterValue.toLowerCase())
      );
      if (!newSelectOptions.length) {
        newSelectOptions = [
          {
            isAriaDisabled: true,
            children: `No results found for "${filterValue}"`,
            value: NO_RESULTS,
          },
        ];
      }
      if (!isOpen) {
        setIsOpen(true);
      }
    }
    setSelectOptions(newSelectOptions);
  }, [filterValue, isOpen, options]);

  const createItemId = value =>
    `select-typeahead-${String(value || '').replace(' ', '-')}`;
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
  const onInputClick = () => {
    if (!isOpen) {
      setIsOpen(true);
    } else if (!inputText) {
      closeMenu();
    }
  };
  const selectOption = (value, content) => {
    // console.log('selected', content);
    setInputText(String(content));
    setFilterValue('');
    setSelected(String(value));
    onChange([{ value }]);
    closeMenu();
  };
  const onSelect = (_event, value) => {
    if (value && value !== NO_RESULTS) {
      const optionText = selectOptions.find(option => option.value === value);
      selectOption(value, optionText?.label || optionText?.children);
    }
  };
  const onTextInputChange = (_event, value) => {
    setInputText(value);
    setFilterValue(value);
    resetActiveAndFocusedItem();
    if (value !== selected) {
      setSelected('');
    }
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
    switch (event.key) {
      case 'Enter':
        if (
          isOpen &&
          focusedItem &&
          focusedItem.value !== NO_RESULTS &&
          !focusedItem.isAriaDisabled
        ) {
          selectOption(focusedItem.value, focusedItem.children);
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
      default:
        break;
    }
  };
  const onToggleClick = () => {
    setIsOpen(!isOpen);
    // eslint-disable-next-line no-unused-expressions
    textInputRef?.current?.focus();
  };
  const onClearButtonClick = () => {
    setSelected('');
    setInputText('');
    setFilterValue('');
    resetActiveAndFocusedItem();
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
      isFullWidth
    >
      <TextInputGroup isPlain>
        <TextInputGroupMain
          value={inputText}
          onClick={onInputClick}
          onChange={onTextInputChange}
          onKeyDown={onInputKeyDown}
          id="typeahead-select-input"
          autoComplete="off"
          innerRef={textInputRef}
          placeholder={placeholder}
          {...(activeItemId && {
            'aria-activedescendant': activeItemId,
          })}
          role="combobox"
          isExpanded={isOpen}
          aria-controls="select-typeahead-listbox"
        />

        <TextInputGroupUtilities
          {...(!inputText
            ? {
                style: {
                  display: 'none',
                },
              }
            : {})}
        >
          <Button
            ouiaId="clear-typeahead-button"
            variant="plain"
            onClick={onClearButtonClick}
            aria-label="Clear input value"
          >
            <TimesIcon aria-hidden />
          </Button>
        </TextInputGroupUtilities>
      </TextInputGroup>
    </MenuToggle>
  );
  return (
    <Select
      ouiaId="typeahead-select"
      id="typeahead-select"
      isOpen={isOpen}
      selected={selected}
      onSelect={onSelect}
      onOpenChange={openState => {
        !openState && closeMenu();
      }}
      toggle={toggle}
      shouldFocusFirstItemOnOpen={false}
    >
      <SelectList id="select-typeahead-listbox">
        {selectOptions.map((option, index) => (
          <SelectOption
            key={option.value || option.children}
            isFocused={focusedItemIndex === index}
            className={option.className}
            id={createItemId(option.value)}
            {...option}
            ref={null}
          >
            {option.label || option.children}
          </SelectOption>
        ))}
      </SelectList>
    </Select>
  );
};

TypeAheadSelect.propTypes = {
  placeholder: PropTypes.string,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
        .isRequired,
      label: PropTypes.string.isRequired,
      className: PropTypes.string,
    })
  ).isRequired,
  onChange: PropTypes.func.isRequired,
  selectedItem: PropTypes.array,
};

TypeAheadSelect.defaultProps = {
  placeholder: '',
  selectedItem: [],
};

export default TypeAheadSelect;
