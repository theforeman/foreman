import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { CogIcon } from '@patternfly/react-icons';
import {
  Button,
  Checkbox,
  FormGroup,
  Icon,
  MenuToggle,
  Popover,
  PopoverPosition,
  Select,
  SelectList,
  SelectOption,
  Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

const SettingsSelect = ({
  id,
  label,
  disabled,
  options,
  selected,
  onSelect,
}) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <FormGroup label={label} fieldId={id} isInline>
      <Select
        id={id}
        ouiaId={id}
        isOpen={isOpen}
        selected={selected}
        onSelect={(_event, selection) => {
          onSelect(selection);
          setIsOpen(false);
        }}
        onOpenChange={setIsOpen}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            ouiaId="editor-settings-toggle"
            onClick={() => {
              if (!disabled) {
                setIsOpen(!isOpen);
              }
            }}
            isExpanded={isOpen}
            isDisabled={disabled}
            isFullWidth
          >
            {selected}
          </MenuToggle>
        )}
      >
        <SelectList id="settings-dropdown">
          {options.map(option => (
            <SelectOption key={option} value={option}>
              {option}
            </SelectOption>
          ))}
        </SelectList>
      </Select>
    </FormGroup>
  );
};

SettingsSelect.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  disabled: PropTypes.bool,
  options: PropTypes.arrayOf(PropTypes.string).isRequired,
  selected: PropTypes.string.isRequired,
  onSelect: PropTypes.func.isRequired,
};

SettingsSelect.defaultProps = {
  disabled: false,
};

const EditorSettings = ({
  selectedView,
  changeSetting,
  keyBinding,
  keyBindings,
  mode,
  modes,
  theme,
  themes,
  autocompletion,
  liveAutocompletion,
}) => (
  <>
    <Popover
      id="cog-popover"
      position={PopoverPosition.bottom}
      enableFlip={false}
      hasAutoWidth
      headerContent={__('Settings')}
      bodyContent={
        <div>
          <SettingsSelect
            id="mode-dropdown"
            label={__('Syntax')}
            disabled={selectedView === 'preview'}
            options={modes}
            selected={mode}
            onSelect={selection => changeSetting({ mode: selection })}
          />
          <SettingsSelect
            id="keybindings-dropdown"
            label={__('Keybind')}
            disabled={selectedView === 'preview'}
            options={keyBindings}
            selected={keyBinding}
            onSelect={selection => changeSetting({ keyBinding: selection })}
          />
          <SettingsSelect
            id="themes-dropdown"
            label={__('Theme')}
            options={themes}
            selected={theme}
            onSelect={selection => changeSetting({ theme: selection })}
          />
          <Checkbox
            id="autocompletion-checkbox"
            ouiaId="autocompletion-checkbox"
            label={__('Autocompletion')}
            isChecked={autocompletion}
            onChange={() => changeSetting({ autocompletion: !autocompletion })}
          />
          <Checkbox
            id="live-autocompletion-checkbox"
            ouiaId="live-autocompletion-checkbox"
            label={__('Live Autocompletion')}
            isChecked={liveAutocompletion}
            isDisabled={!autocompletion}
            onChange={() =>
              changeSetting({ liveAutocompletion: !liveAutocompletion })
            }
          />
        </div>
      }
      triggerRef={() => document.getElementById('cog-btn')}
    />
    <Tooltip content={__('Settings')} position={TooltipPosition.top}>
      <Button
        variant="plain"
        className="editor-button"
        id="cog-btn"
        ouiaId="cog-btn"
        aria-label={__('Settings')}
      >
        <Icon size="md">
          <CogIcon />
        </Icon>
      </Button>
    </Tooltip>
  </>
);

EditorSettings.propTypes = {
  changeSetting: PropTypes.func.isRequired,
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  selectedView: PropTypes.string.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  theme: PropTypes.string.isRequired,
  themes: PropTypes.array.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
};

export default EditorSettings;
