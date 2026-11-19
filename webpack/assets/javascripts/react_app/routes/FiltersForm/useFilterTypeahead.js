import { useEffect, useMemo, useState } from 'react';
import { TYPEAHEAD_NO_FOCUSED_ITEM } from './FiltersFormConstants';

/**
 * State and keyboard handling for FilterTypeaheadSelect: filters options by the
 * typed text and lets ArrowUp/ArrowDown move focus and Enter pick an option.
 */
export const useFilterTypeahead = ({ options, selectedLabel, onSelect }) => {
  const [isOpen, setIsOpen] = useState(false);
  const [inputValue, setInputValue] = useState(selectedLabel);
  const [filterValue, setFilterValue] = useState('');
  const [focusedItemIndex, setFocusedItemIndex] = useState(
    TYPEAHEAD_NO_FOCUSED_ITEM
  );

  useEffect(() => {
    setInputValue(selectedLabel);
  }, [selectedLabel]);

  const filteredOptions = useMemo(() => {
    if (!filterValue) return options;
    const search = filterValue.toLowerCase();
    return options.filter(option =>
      option.label.toLowerCase().includes(search)
    );
  }, [filterValue, options]);

  const resetMenu = () => {
    setIsOpen(false);
    setFilterValue('');
    setFocusedItemIndex(TYPEAHEAD_NO_FOCUSED_ITEM);
  };

  // closing without a choice drops the typed text and shows the selection again
  const closeMenu = () => {
    resetMenu();
    setInputValue(selectedLabel);
  };

  const selectOption = value => {
    const option = options.find(item => item.value === value);
    if (!option) return;
    resetMenu();
    setInputValue(option.label);
    onSelect(option.value);
  };

  const onTextInputChange = (_event, value) => {
    setInputValue(value);
    setFilterValue(value);
    setFocusedItemIndex(TYPEAHEAD_NO_FOCUSED_ITEM);
    setIsOpen(true);
  };

  const clearInput = () => {
    setInputValue('');
    setFilterValue('');
  };

  const onInputKeyDown = event => {
    const lastIndex = filteredOptions.length - 1;
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        setIsOpen(true);
        setFocusedItemIndex(index => (index >= lastIndex ? 0 : index + 1));
        break;
      case 'ArrowUp':
        event.preventDefault();
        setIsOpen(true);
        setFocusedItemIndex(index => (index <= 0 ? lastIndex : index - 1));
        break;
      case 'Enter':
        event.preventDefault();
        if (isOpen && filteredOptions[focusedItemIndex]) {
          selectOption(filteredOptions[focusedItemIndex].value);
        } else {
          setIsOpen(!isOpen);
        }
        break;
      default:
        break;
    }
  };

  return {
    isOpen,
    setIsOpen,
    inputValue,
    filterValue,
    filteredOptions,
    focusedItemIndex,
    closeMenu,
    selectOption,
    clearInput,
    onTextInputChange,
    onInputKeyDown,
  };
};
