import React from 'react';
import PropTypes from 'prop-types';
import { Dropdown, VerticalNav, Icon, MenuItem } from 'patternfly-react';
import NotificationContainer from '../../notifications';
import NavDropdown from './NavDropdown';
import NavItem from './NavItem';

const UserDropdowns = ({
  activeKey,
  activeHref,
  user,
  notificationUrl,
  ...props
}) => (
  <VerticalNav.IconBar>
    <NavItem
      className="drawer-pf-trigger dropdown notifification-dropdown"
      id="notifications_container"
    >
      <NotificationContainer data={{ url: notificationUrl }} />
    </NavItem>
    <NavDropdown componentClass="li" id="account_menu">
      <Dropdown.Toggle useAnchor className="nav-item-iconic">
        <Icon type="fa" name="user avatar small" /> {user[0].name}
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {user[0].children.map((item, i) =>
            (item.type === 'divider' ? (
              <MenuItem key={i} divider />
            ) : (
              <MenuItem key={i} href={item.url}>
                {__(item.name)}
              </MenuItem>
            )))}
      </Dropdown.Menu>
    </NavDropdown>
  </VerticalNav.IconBar>
);

UserDropdowns.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** User Data Array */
  user: PropTypes.array,
  /** notification URL */
  notificationUrl: PropTypes.string,
};
UserDropdowns.defaultProps = {
  className: '',
  user: [],
  notificationUrl: '',
};
export default UserDropdowns;
