import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { VerticalNav } from 'patternfly-react';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  DropdownSeparator,
} from '@patternfly/react-core';
import { UserAltIcon } from '@patternfly/react-icons';

import { userPropType } from '../LayoutHelper';
import NotificationContainer from '../../notifications';
import NavItem from './NavItem';
import ImpersonateIcon from './ImpersonateIcon';
import InstanceTitleViewer from './InstanceTitleViewer';
import { translate as __ } from '../../../common/I18n';

const UserDropdowns = ({
  user,
  changeActiveMenu,
  notificationUrl,
  stopImpersonationUrl,
  instanceTitle,
  ...props
}) => {
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);

  const onDropdownToggle = newUserDropdownOpen => {
    setUserDropdownOpen(newUserDropdownOpen);
  };
  const onDropdownSelect = () => {
    setUserDropdownOpen(userDropdownOpen);
  };
  const userInfo = user.current_user;
  const impersonateIcon = (
    <ImpersonateIcon stopImpersonationUrl={stopImpersonationUrl} />
  );

  const userDropdownItems = user.user_dropdown[0].children.map((item, i) =>
    item.type === 'divider' ? (
      <DropdownSeparator key={i} />
    ) : (
      <DropdownItem
        key={i}
        className="user_menuitem"
        href={item.url}
        onClick={() => {
          changeActiveMenu({ title: 'User' });
        }}
        {...item.html_options}
      >
        {__(item.name)}
      </DropdownItem>
    )
  );

  return (
    <VerticalNav.IconBar {...props}>
      <InstanceTitleViewer title={instanceTitle} />
      <NavItem
        className="drawer-pf-trigger dropdown notification-dropdown"
        id="notifications_container"
      >
        <NotificationContainer data={{ url: notificationUrl }} />
      </NavItem>
      {user.impersonated_by && impersonateIcon}
      <NavItem id="account_menu" className="pf-c-page__header">
        {userInfo && (
          <Dropdown
            isPlain
            position="right"
            onSelect={onDropdownSelect}
            isOpen={userDropdownOpen}
            toggle={
              <DropdownToggle onToggle={onDropdownToggle}>
                <UserAltIcon className="user-icon" />
                {userInfo.name}
              </DropdownToggle>
            }
            dropdownItems={userDropdownItems}
            {...props}
          />
        )}
      </NavItem>
    </VerticalNav.IconBar>
  );
};

UserDropdowns.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** User Data Array */
  user: userPropType,
  /** notification URL */
  notificationUrl: PropTypes.string,
  /** changeActiveMenu Func */
  changeActiveMenu: PropTypes.func,
  stopImpersonationUrl: PropTypes.string,
  instanceTitle: PropTypes.string,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  notificationUrl: '',
  changeActiveMenu: null,
  stopImpersonationUrl: '',
  instanceTitle: '',
};
export default UserDropdowns;
