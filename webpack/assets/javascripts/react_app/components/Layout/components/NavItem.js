import React from 'react';
import PropTypes from 'prop-types';

const NavItem = ({ activeKey, activeHref, children, className, ...props }) => (
  <li className={className} {...props}>
    {children}
  </li>
);
NavItem.propTypes = {
  /** Child node - contents of the element */
  children: PropTypes.node.isRequired,
  /** Additional element css classes */
  className: PropTypes.string,
  /** activeKey, activeHref props for bootstrap navItems */
  activeHref: PropTypes.string,
  activeKey: PropTypes.string,
};
NavItem.defaultProps = {
  className: '',
  activeHref: '',
  activeKey: '',
};
export default NavItem;
