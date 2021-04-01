import React from 'react';
import PropTypes from 'prop-types';

const LinkOrLabel = ({ label, path }) => {
  if (path) {
    return <a href={path}>{label}</a>;
  }
  return <span>{label}</span>;
};

LinkOrLabel.propTypes = {
  label: PropTypes.string.isRequired,
  path: PropTypes.string,
};

LinkOrLabel.defaultProps = {
  path: undefined,
};

export default LinkOrLabel;
