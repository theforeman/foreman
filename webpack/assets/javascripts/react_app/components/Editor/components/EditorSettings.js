import React from 'react';
import PropTypes from 'prop-types';
import {
  Popover,
  Dropdown,
  MenuItem,
  Button,
  Icon,
  OverlayTrigger,
} from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';

const EditorSettings = ({
  selectedView,
  changeSetting,
  keyBinding,
  keyBindings,
  mode,
  modes,
  theme,
  themes,
}) => (
  <OverlayTrigger
    overlay={
      <Popover placement="bottom" title={__('Settings')} id="cog-popover">
        <div className="cog-popover-dropdown">
          <div className="cog-popover-dropdown-title">{__('Syntax')}</div>
          <Dropdown disabled={selectedView === 'preview'} id="mode-dropdown">
            <Dropdown.Toggle>{mode}</Dropdown.Toggle>
            <Dropdown.Menu id="settings-dropdown">
              {modes.map((aceMode, i) => (
                <MenuItem
                  key={i}
                  onClick={() => changeSetting({ mode: aceMode })}
                >
                  {aceMode}
                </MenuItem>
              ))}
            </Dropdown.Menu>
          </Dropdown>
        </div>
        <div className="cog-popover-dropdown">
          <div className="cog-popover-dropdown-title">{__('Keybind')}</div>
          <Dropdown
            disabled={selectedView === 'preview'}
            id="keybindings-dropdown"
          >
            <Dropdown.Toggle>{keyBinding}</Dropdown.Toggle>
            <Dropdown.Menu id="settings-dropdown">
              {keyBindings.map((keyBind, i) => (
                <MenuItem
                  key={i}
                  onClick={() => changeSetting({ keyBinding: keyBind })}
                >
                  {keyBind}
                </MenuItem>
              ))}
            </Dropdown.Menu>
          </Dropdown>
        </div>
        <div className="cog-popover-dropdown">
          <div className="cog-popover-dropdown-title">{__('Theme')}</div>
          <Dropdown id="themes-dropdown">
            <Dropdown.Toggle>{theme}</Dropdown.Toggle>
            <Dropdown.Menu id="settings-dropdown">
              {themes.map((themeKey, i) => (
                <MenuItem
                  key={i}
                  onClick={() => changeSetting({ theme: themeKey })}
                >
                  {themeKey}
                </MenuItem>
              ))}
            </Dropdown.Menu>
          </Dropdown>
        </div>
      </Popover>
    }
    placement="bottom"
    trigger={['click']}
    rootClose
  >
    <Button className="editor-button" id="cog-btn" bsStyle="link">
      <Icon size="lg" name="cog" />
    </Button>
  </OverlayTrigger>
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
};

export default EditorSettings;
