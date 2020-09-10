import React from 'react';
import PropTypes from 'prop-types';
import './Text.scss';

const Text = ({ children }) => <div className="text">{children}</div>;

Text.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]),
};

Text.defaultProps = {
  children: null,
};

export default Text;
