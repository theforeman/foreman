import React from 'react';
import PropTypes from 'prop-types';

import { noop } from '../../../common/helpers';
import CommonForm from './CommonForm';

const Checkbox = ({ className, checked, onChange, label, disabled }) => (
  <CommonForm label={label} className={`common-checkbox ${className}`}>
    <input
      disabled={disabled}
      type="checkbox"
      checked={checked}
      onChange={onChange}
    />
  </CommonForm>
);

Checkbox.propTypes = {
  className: PropTypes.string,
  checked: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  label: PropTypes.string,
  disabled: PropTypes.bool,
  onChange: PropTypes.func,
};

Checkbox.defaultProps = {
  className: '',
  checked: false,
  label: '',
  disabled: false,
  onChange: noop,
};

export default Checkbox;
