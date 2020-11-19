import React from 'react';
import PropTypes from 'prop-types';

const StringValue = ({
  id,
  name,
  css,
  value,
  onChange,
  fullScreen,
  isMasked,
}) => (
  <textarea
    id={id}
    name={name}
    rows={fullScreen ? 30 : 1}
    className={`${css} ${isMasked && 'masked-input'}`}
    value={value}
    onChange={e => onChange(e.target.value)}
  />
);

StringValue.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string.isRequired,
  css: PropTypes.string,
  value: PropTypes.any,
  onChange: PropTypes.func.isRequired,
  fullScreen: PropTypes.bool,
  isMasked: PropTypes.bool,
};

StringValue.defaultProps = {
  id: '',
  css: '',
  fullScreen: false,
  value: '',
  isMasked: false,
};

export default StringValue;
