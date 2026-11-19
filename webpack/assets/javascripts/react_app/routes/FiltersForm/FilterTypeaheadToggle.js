import React from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  MenuToggle,
  TextInputGroup,
  TextInputGroupMain,
  TextInputGroupUtilities,
} from '@patternfly/react-core';
import { TimesIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../common/I18n';

export const FilterTypeaheadToggle = ({
  toggleRef,
  toggleAriaLabel,
  inputAriaLabel,
  listboxId,
  activeDescendantId,
  isOpen,
  inputValue,
  onToggleClick,
  onInputClick,
  onTextInputChange,
  onInputKeyDown,
  onClear,
}) => (
  <MenuToggle
    ref={toggleRef}
    variant="typeahead"
    aria-label={toggleAriaLabel}
    onClick={onToggleClick}
    isExpanded={isOpen}
    isFullWidth
  >
    <TextInputGroup isPlain>
      <TextInputGroupMain
        value={inputValue}
        aria-label={inputAriaLabel}
        onClick={onInputClick}
        onChange={onTextInputChange}
        onKeyDown={onInputKeyDown}
        autoComplete="off"
        role="combobox"
        isExpanded={isOpen}
        aria-controls={listboxId}
        {...(activeDescendantId && {
          'aria-activedescendant': activeDescendantId,
        })}
      />
      {inputValue && (
        <TextInputGroupUtilities>
          <Button
            variant="plain"
            aria-label={__('Clear input value')}
            onClick={onClear}
            icon={<TimesIcon />}
          />
        </TextInputGroupUtilities>
      )}
    </TextInputGroup>
  </MenuToggle>
);

FilterTypeaheadToggle.propTypes = {
  toggleRef: PropTypes.oneOfType([PropTypes.func, PropTypes.object]).isRequired,
  toggleAriaLabel: PropTypes.string.isRequired,
  inputAriaLabel: PropTypes.string.isRequired,
  listboxId: PropTypes.string.isRequired,
  activeDescendantId: PropTypes.string,
  isOpen: PropTypes.bool.isRequired,
  inputValue: PropTypes.string,
  onToggleClick: PropTypes.func.isRequired,
  onInputClick: PropTypes.func.isRequired,
  onTextInputChange: PropTypes.func.isRequired,
  onInputKeyDown: PropTypes.func.isRequired,
  onClear: PropTypes.func.isRequired,
};

FilterTypeaheadToggle.defaultProps = {
  activeDescendantId: undefined,
  inputValue: '',
};
