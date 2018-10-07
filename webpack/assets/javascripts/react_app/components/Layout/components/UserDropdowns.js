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
  changeActiveMenu,
  notificationUrl,
  ...props
}) => (
  <VerticalNav.IconBar {...props}>
    {!!user && (
      <NavItem
        className="drawer-pf-trigger dropdown notification-dropdown"
        id="notifications_container"
      >
        <NotificationContainer data={{ url: notificationUrl }} />
      </NavItem>
    )}
    {!!user &&
      !!user.current_user && (
        <NavDropdown componentClass="li" id="account_menu">
          <Dropdown.Toggle useAnchor className="nav-item-iconic">
            <Icon type="fa" name="user avatar small" />
            {user.current_user.user.firstname} {user.current_user.user.lastname}
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {user.user_dropdown[0].children.map((item, i) =>
                (item.type === 'divider' ? (
                  <MenuItem key={i} divider />
                ) : (
                  <MenuItem
                    key={i}
                    className="user_menuitem"
                    href={item.url}
                    onClick={() => {
                      changeActiveMenu({ title: 'User' });
                    }}
                  >
                    {__(item.name)}
                  </MenuItem>
                )))}
          </Dropdown.Menu>
        </NavDropdown>
      )}
  </VerticalNav.IconBar>
);

UserDropdowns.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** User Data Array */
  user: PropTypes.object,
  /** notification URL */
  notificationUrl: PropTypes.string,
  /** changeActiveMenu Func */
  changeActiveMenu: PropTypes.func,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  notificationUrl: '',
  changeActiveMenu: null,
};
export default UserDropdowns;
