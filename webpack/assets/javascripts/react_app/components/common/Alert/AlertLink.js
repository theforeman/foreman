import React from 'react';
import PropTypes from 'prop-types';

const AlertLink = ({ children, ...props }) => (
  <div className="pull-right toast-pf-action">
    <a {...props}>{children}</a>
  </div>
);

AlertLink.propTypes = {
  children: PropTypes.string.isRequired,
  href: PropTypes.string,
  onClick: PropTypes.func,
};

AlertLink.defaultProps = {
  href: undefined,
  onClick: undefined,
};

export default AlertLink;
