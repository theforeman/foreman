import React from 'react';
import PropTypes from 'prop-types';

const NumberValue = ({ id, name, css, value, onChange, isMasked }) => (
  <input
    type="number"
    id={id}
    name={name}
    className={`${css} ${isMasked && 'masked-input'}`}
    value={value}
    onChange={e => onChange(e.target.value)}
  />
);

NumberValue.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string.isRequired,
  css: PropTypes.string,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
  isMasked: PropTypes.bool,
};

NumberValue.defaultProps = {
  id: '',
  css: '',
  value: '',
  isMasked: false,
};

export default NumberValue;
