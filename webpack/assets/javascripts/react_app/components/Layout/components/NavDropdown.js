import React from 'react';
import PropTypes from 'prop-types';
import { Dropdown } from 'patternfly-react';

const NavDropdown = ({
  activeKey,
  activeHref,
  children,
  ...props
}) => (
    <Dropdown componentClass="li" id="account_menu" {...props}>
      {children}
    </Dropdown>
);
NavDropdown.propTypes = {
  /** Child node - contents of the element */
  children: PropTypes.node.isRequired,
  /** Additional element css classes */
  className: PropTypes.string,
};
NavDropdown.defaultProps = {
  className: '',
};
export default NavDropdown;
