import React from 'react';
import PropTypes from 'prop-types';
import getIconClass from './Icon.consts';

const Icon = ({ className, type }) => (
  <span
    className={`${getIconClass(type)}${className ? ` ${className}` : ''}`}
  />
);

Icon.propTypes = {
  type: PropTypes.string.isRequired,
  className: PropTypes.string,
};

Icon.defaultProps = {
  className: '',
};

export default Icon;
