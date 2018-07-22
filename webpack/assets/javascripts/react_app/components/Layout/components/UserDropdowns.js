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
  userDropdown,
  changeActiveMenu,
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
        <Icon type="fa" name="user avatar small" /> {user.user.firstname}{' '}
        {user.user.lastname}
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {userDropdown[0].children.map((item, i) =>
            (item.type === 'divider' ? (
              <MenuItem key={i} divider />
            ) : (
              <MenuItem
                key={i}
                onClick={() => {
                  changeActiveMenu({ title: 'User' });
                  window.Turbolinks.visit(item.url);
                }}
              >
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
  user: PropTypes.object,
  /** UserDropdowns */
  userDropdown: PropTypes.array,
  /** notification URL */
  notificationUrl: PropTypes.string,
  /** changeActiveMenu Func */
  changeActiveMenu: PropTypes.func,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  userDropdown: [],
  notificationUrl: '',
  changeActiveMenu: null,
};
export default UserDropdowns;
