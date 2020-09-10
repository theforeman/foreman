import React from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'patternfly-react';

const NavDropdown = ({ activeKey, activeHref, children, ...props }) => (
  <Dropdown componentClass="li" id="account_menu" {...props}>
    {children}
  </Dropdown>
);
NavDropdown.propTypes = {
  /** Child node - contents of the element */
  children: PropTypes.node.isRequired,
  /** Additional element css classes */
  className: PropTypes.string,
  /** activeKey, activeHref props for bootstrap navItems */
  activeHref: PropTypes.string,
  activeKey: PropTypes.string,
};
NavDropdown.defaultProps = {
  className: '',
  activeHref: '',
  activeKey: '',
};
export default NavDropdown;
