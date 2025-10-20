import React from 'react';
import PropTypes from 'prop-types';
import { Checkbox } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

const EditorSafemodeCheckbox = ({
  show,
  checked,
  disabled,
  handleSafeModeChange,
}) => {
  if (show) {
    return (
      <Checkbox
        ouiaId="safemode-rendering-switch"
        id="safemode-rendering-checkbox"
        className="safemode-rendering-checkbox"
        label={__('Safemode')}
        isChecked={checked}
        isDisabled={disabled}
        onChange={handleSafeModeChange}
        isLabelBeforeButton
      />
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
