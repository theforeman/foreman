import React from 'react';
import PropTypes from 'prop-types';
import CommonForm from './CommonForm';
import { noop } from '../../../common/helpers';

const Checkbox = ({ className = '', checked, onChange, label, disabled }) => (
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
  checked: PropTypes.bool,
  label: PropTypes.node,
  disabled: PropTypes.bool,
  onChange: PropTypes.func,
};

Checkbox.defaultProps = {
  className: '',
  checked: false,
  label: null,
  disabled: false,
  onChange: noop,
};

export default Checkbox;
