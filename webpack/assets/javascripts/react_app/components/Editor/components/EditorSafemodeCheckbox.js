import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import './editorsafemodecheckbox.scss';

const EditorSafemodeCheckbox = ({
  show,
  checked,
  disabled,
  handleSafeModeChange,
}) => {
  if (show) {
    return (
      <React.Fragment>
        <label
          className="safemode-rendering-checkbox"
          htmlFor="safemode-rendering-checkbox"
        >
          {__('Safemode')}
        </label>
        <input
          type="checkbox"
          id="safemode-rendering-checkbox"
          onChange={handleSafeModeChange}
          checked={checked}
          disabled={disabled}
        />
      </React.Fragment>
    );
  }
  return null;
};

EditorSafemodeCheckbox.propTypes = {
  show: PropTypes.bool.isRequired,
  checked: PropTypes.bool.isRequired,
  disabled: PropTypes.bool.isRequired,
  handleSafeModeChange: PropTypes.func.isRequired,
};

export default EditorSafemodeCheckbox;
