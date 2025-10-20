import React from 'react';
import PropTypes from 'prop-types';
import { CogIcon } from '@patternfly/react-icons';
import {
  Button,
  Checkbox,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Icon,
  Popover,
  PopoverPosition,
  Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { EDITOR_TAB_NAMES } from '../EditorConstants';

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
      position={PopoverPosition.auto}
      enableFlip={false}
      hasAutoWidth
      headerContent={__('Settings')}
      bodyContent={
        <Form>
          <FormGroup label={__('Syntax')} fieldId="mode-select">
            <FormSelect
              ouiaId="mode-select"
              id="mode-select"
              value={mode}
              onChange={(_event, value) => changeSetting({ mode: value })}
              isDisabled={selectedView === EDITOR_TAB_NAMES.preview}
            >
              {modes.map((aceMode, i) => (
                <FormSelectOption key={i} value={aceMode} label={aceMode} />
              ))}
            </FormSelect>
          </FormGroup>
          <FormGroup label={__('Keybind')} fieldId="keybindings-select">
            <FormSelect
              ouiaId="keybindings-select"
              id="keybindings-select"
              value={keyBinding}
              onChange={(_event, value) => changeSetting({ keyBinding: value })}
              isDisabled={selectedView === EDITOR_TAB_NAMES.preview}
            >
              {keyBindings.map((keyBind, i) => (
                <FormSelectOption key={i} value={keyBind} label={keyBind} />
              ))}
            </FormSelect>
          </FormGroup>
          <FormGroup label={__('Theme')} fieldId="themes-select">
            <FormSelect
              ouiaId="themes-select"
              id="themes-select"
              value={theme}
              onChange={(_event, value) => changeSetting({ theme: value })}
            >
              {themes.map((themeKey, i) => (
                <FormSelectOption key={i} value={themeKey} label={themeKey} />
              ))}
            </FormSelect>
          </FormGroup>
          <FormGroup
            label={__('Autocompletion')}
            fieldId="autocompletion-checkbox"
          >
            <Checkbox
              ouiaId="autocompletion-checkbox"
              id="autocompletion-checkbox"
              name="autocompletion"
              isChecked={autocompletion}
              onChange={(_event, value) =>
                changeSetting({ autocompletion: value })
              }
              label={__('Enable autocompletion')}
            />
          </FormGroup>
          <FormGroup
            label={__('Live Autocompletion')}
            fieldId="live-autocompletion-checkbox"
          >
            <Checkbox
              ouiaId="live-autocompletion-checkbox"
              id="live-autocompletion-checkbox"
              name="liveAutocompletion"
              isChecked={liveAutocompletion}
              isDisabled={!autocompletion}
              onChange={(_event, value) =>
                changeSetting({ liveAutocompletion: value })
              }
              label={__('Enable live autocompletion')}
            />
          </FormGroup>
        </Form>
      }
      triggerRef={() => document.getElementById('settings-btn')}
    />
    <Tooltip content={__('Settings')} position={TooltipPosition.top}>
      <Button
        ouiaId="editor-settings-button"
        className="editor-button"
        id="settings-btn"
        variant="link"
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
