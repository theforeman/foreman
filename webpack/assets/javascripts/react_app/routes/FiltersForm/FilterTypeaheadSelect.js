import React from 'react';
import PropTypes from 'prop-types';
import { Select, SelectList, SelectOption } from '@patternfly/react-core';
import { sprintf, translate as __ } from '../../common/I18n';
import { TYPEAHEAD_NO_RESULTS_VALUE } from './FiltersFormConstants';
import { useFilterTypeahead } from './useFilterTypeahead';
import { FilterTypeaheadToggle } from './FilterTypeaheadToggle';

/**
 * Single typeahead select for the filter form, based on the PF6 composable
 * typeahead example. Unlike the react-templates TypeaheadSelect it lets us
 * label the text input, so the role and resource type inputs stay distinguishable.
 */
export const FilterTypeaheadSelect = ({
  ouiaId,
  inputAriaLabel,
  toggleAriaLabel,
  options,
  selectedLabel,
  onSelect,
}) => {
  const typeahead = useFilterTypeahead({ options, selectedLabel, onSelect });
  const { isOpen, filteredOptions, focusedItemIndex } = typeahead;
  const listboxId = `${ouiaId}-listbox`;
  const optionId = value => `${ouiaId}-option-${value}`;
  const focusedOption = filteredOptions[focusedItemIndex];

  return (
    <Select
      ouiaId={`${ouiaId}-menu`}
      className="without_select2"
      variant="typeahead"
      isOpen={isOpen}
      onOpenChange={newIsOpen => !newIsOpen && typeahead.closeMenu()}
      onSelect={(_event, value) =>
        value !== TYPEAHEAD_NO_RESULTS_VALUE && typeahead.selectOption(value)
      }
      toggle={toggleRef => (
        <FilterTypeaheadToggle
          ouiaId={ouiaId}
          toggleRef={toggleRef}
          toggleAriaLabel={toggleAriaLabel}
          inputAriaLabel={inputAriaLabel}
          listboxId={listboxId}
          activeDescendantId={focusedOption && optionId(focusedOption.value)}
          isOpen={isOpen}
          inputValue={typeahead.inputValue}
          onToggleClick={() =>
            isOpen ? typeahead.closeMenu() : typeahead.setIsOpen(true)
          }
          onInputClick={() => typeahead.setIsOpen(!isOpen)}
          onTextInputChange={typeahead.onTextInputChange}
          onInputKeyDown={typeahead.onInputKeyDown}
          onClear={typeahead.clearInput}
        />
      )}
      maxMenuHeight="45vh"
      isScrollable
    >
      <SelectList id={listboxId}>
        {filteredOptions.length ? (
          filteredOptions.map((option, index) => (
            <SelectOption
              key={option.value}
              id={optionId(option.value)}
              value={option.value}
              isFocused={index === focusedItemIndex}
              isSelected={option.label === selectedLabel}
            >
              {option.label}
            </SelectOption>
          ))
        ) : (
          <SelectOption value={TYPEAHEAD_NO_RESULTS_VALUE} isAriaDisabled>
            {sprintf(__('No results found for "%s"'), typeahead.filterValue)}
          </SelectOption>
        )}
      </SelectList>
    </Select>
  );
};

FilterTypeaheadSelect.propTypes = {
  ouiaId: PropTypes.string.isRequired,
  inputAriaLabel: PropTypes.string.isRequired,
  toggleAriaLabel: PropTypes.string.isRequired,
  options: PropTypes.arrayOf(
    PropTypes.shape({
      value: PropTypes.oneOfType([PropTypes.string, PropTypes.number])
        .isRequired,
      label: PropTypes.string.isRequired,
    })
  ).isRequired,
  selectedLabel: PropTypes.string,
  onSelect: PropTypes.func.isRequired,
};

FilterTypeaheadSelect.defaultProps = {
  selectedLabel: '',
};
