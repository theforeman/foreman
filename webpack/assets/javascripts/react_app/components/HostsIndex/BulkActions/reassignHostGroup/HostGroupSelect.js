import React from 'react';
import {
  Select,
  SelectList,
  MenuToggle,
  TextInputGroup,
  TextInputGroupMain,
  TextInputGroupUtilities,
  Button,
} from '@patternfly/react-core';
import { TimesIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../common/I18n';

const HostGroupSelect = ({
  headerText,
  children,
  onClear,
  selected,
  isOpen,
  onToggle,
  onSelect,
  inputValue,
  onInputValueChange,
  placeholder,
}) => {
  const textInputRef = React.useRef();

  const onToggleClick = () => {
    onToggle(!isOpen);
    if (textInputRef?.current?.focus) {
      textInputRef.current.focus();
    }
  };

  const onClearButtonClick = () => {
    onClear();
    if (textInputRef?.current?.focus) {
      textInputRef.current.focus();
    }
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
          value={inputValue}
          onClick={onToggleClick}
          onChange={(event, value) => onInputValueChange(value)}
          id="typeahead-select-input"
          autoComplete="off"
          innerRef={textInputRef}
          placeholder={placeholder}
          role="combobox"
          isExpanded={isOpen}
          aria-controls="select-typeahead-listbox"
        />
        <TextInputGroupUtilities
          {...(!inputValue ? { style: { display: 'none' } } : {})}
        >
          <Button
            variant="plain"
            onClick={onClearButtonClick}
            aria-label="Clear input value"
            ouiaId="hostgroup-select-clear-button"
          >
            <TimesIcon aria-hidden />
          </Button>
        </TextInputGroupUtilities>
      </TextInputGroup>
    </MenuToggle>
  );

  return (
    <div style={{ marginTop: '1em' }}>
      <h3>{headerText}</h3>
      <Select
        id="typeahead-select"
        isOpen={isOpen}
        selected={selected}
        onSelect={onSelect}
        onOpenChange={isOpenState => {
          if (!isOpenState) {
            onToggle(false);
          }
        }}
        toggle={toggle}
        shouldFocusFirstItemOnOpen={false}
        ouiaId="hostgroup-select"
      >
        <SelectList id="select-typeahead-listbox">{children}</SelectList>
      </Select>
    </div>
  );
};

HostGroupSelect.propTypes = {
  headerText: PropTypes.string,
  onClear: PropTypes.func.isRequired,
  children: PropTypes.node,
  selected: PropTypes.string,
  isOpen: PropTypes.bool,
  onToggle: PropTypes.func.isRequired,
  onSelect: PropTypes.func.isRequired,
  inputValue: PropTypes.string,
  onInputValueChange: PropTypes.func.isRequired,
  placeholder: PropTypes.string,
};

HostGroupSelect.defaultProps = {
  headerText: __('Select host group'),
  children: [],
  selected: '',
  isOpen: false,
  inputValue: '',
  placeholder: __('Select host group'),
};

export default HostGroupSelect;
