import React from 'react';
import PropTypes from 'prop-types';
import { Dropdown, VerticalNav, Icon, MenuItem } from 'patternfly-react';
import get from 'lodash/get';
import NotificationContainer from '../../notifications';
import NavDropdown from './NavDropdown';
import NavItem from './NavItem';
import { translate as __ } from '../../../common/I18n';

const UserDropdowns = ({
  activeKey, // eslint-disable-line react/prop-types
  activeHref, // eslint-disable-line react/prop-types
  user,
  changeActiveMenu,
  notificationUrl,
  ...props
}) => {
  const userInfo = get(user, 'current_user.user');
  return (
    <VerticalNav.IconBar {...props}>
      <NavItem
        className="drawer-pf-trigger dropdown notification-dropdown"
        id="notifications_container"
      >
        <NotificationContainer data={{ url: notificationUrl }} />
      </NavItem>
      {userInfo && (
        <NavDropdown componentClass="li" id="account_menu">
          <Dropdown.Toggle useAnchor className="nav-item-iconic">
            <Icon type="fa" name="user avatar small" />
            {userInfo.firstname} {userInfo.lastname}
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {user.user_dropdown[0].children.map((item, i) =>
              item.type === 'divider' ? (
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
              )
            )}
          </Dropdown.Menu>
        </NavDropdown>
      )}
    </VerticalNav.IconBar>
  );
};

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
