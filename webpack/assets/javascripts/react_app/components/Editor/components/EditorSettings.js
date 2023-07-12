import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { Dropdown, MenuItem, Button, Icon } from 'patternfly-react';
import {
  Popover,
  PopoverPosition,
  Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import { EditorContext } from '../EditorContext';

const EditorSettings = ({
  changeSetting,
  keyBinding,
  keyBindings,
  mode,
  modes,
  theme,
  themes,
  autocompletion,
  liveAutocompletion,
}) => {
  const { selectedView } = useContext(EditorContext);
  return (
    <Popover
      id="cog-popover"
      position={PopoverPosition.bottom}
      enableFlip={false}
      hasAutoWidth
      headerContent={__('Settings')}
      bodyContent={
        <div>
          <div className="cog-popover-dropdown">
            <div className="cog-popover-dropdown-title">{__('Syntax')}</div>
            <Dropdown
              disabled={selectedView === 'preview'}
              id="syntax-dropdown"
              data-testid="syntax-dropdown-menu"
            >
              <Dropdown.Toggle>{mode}</Dropdown.Toggle>
              <Dropdown.Menu id="settings-dropdown">
                {modes.map((aceMode, i) => (
                  <MenuItem
                    key={i}
                    aria-label="Syntax dropdown item"
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
              aria-label="Keybindings dropdown"
            >
              <Dropdown.Toggle>{keyBinding}</Dropdown.Toggle>
              <Dropdown.Menu id="settings-dropdown">
                {keyBindings.map((keyBind, i) => (
                  <MenuItem
                    key={i}
                    aria-label="Keybinding dropdown item"
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
            <Dropdown id="themes-dropdown" aria-label="Themes dropdown">
              <Dropdown.Toggle>{theme}</Dropdown.Toggle>
              <Dropdown.Menu id="settings-dropdown">
                {themes.map((themeKey, i) => (
                  <MenuItem
                    key={i}
                    aria-label="Theme dropdown item"
                    onClick={() => changeSetting({ theme: themeKey })}
                  >
                    {themeKey}
                  </MenuItem>
                ))}
              </Dropdown.Menu>
            </Dropdown>
          </div>
          <div className="cog-popover-dropdown">
            <div className="cog-popover-dropdown-title">
              {__('Autocompletion')}
            </div>
            <div className="dropdown btn-group">
              <input
                id="autocompletion-checkbox"
                name="autocompletion"
                type="checkbox"
                checked={autocompletion}
                onChange={e =>
                  changeSetting({ autocompletion: !autocompletion })
                }
                aria-label="autocompletion input"
              />
            </div>
          </div>
          <div className="cog-popover-dropdown">
            <div className="cog-popover-dropdown-title">
              {__('Live Autocompletion')}
            </div>
            <div className="dropdown btn-group">
              <input
                id="live-autocompletion-checkbox"
                name="liveAutocompletion"
                type="checkbox"
                aria-label="autocompletion live input"
                checked={liveAutocompletion}
                disabled={!autocompletion}
                onChange={e =>
                  changeSetting({ liveAutocompletion: !liveAutocompletion })
                }
              />
            </div>
          </div>
        </div>
      }
    >
      <div>
        <Tooltip content={__('Settings')} position={TooltipPosition.top}>
          <Button
            className="editor-button"
            id="cog-btn"
            bsStyle="link"
            aria-label="Editor settings open button"
          >
            <Icon size="lg" name="cog" />
          </Button>
        </Tooltip>
      </div>
    </Popover>
  );
};

EditorSettings.propTypes = {
  changeSetting: PropTypes.func.isRequired,
  keyBinding: PropTypes.string.isRequired,
  keyBindings: PropTypes.array.isRequired,
  mode: PropTypes.string.isRequired,
  modes: PropTypes.array.isRequired,
  theme: PropTypes.string.isRequired,
  themes: PropTypes.array.isRequired,
  autocompletion: PropTypes.bool.isRequired,
  liveAutocompletion: PropTypes.bool.isRequired,
};

export default EditorSettings;
