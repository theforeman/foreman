import React, { useMemo, useState } from 'react';
import PropTypes from 'prop-types';
import {
  Divider,
  Dropdown,
  DropdownItem,
  DropdownList,
  MenuToggle,
} from '@patternfly/react-core';
import { UserAltIcon } from '@patternfly/react-icons';

import { userPropType } from '../../LayoutHelper';
import { translate as __ } from '../../../../common/I18n';
import { createMenuLinkComponent } from '../../../common/MenuLink';

const UserDropdowns = ({ user, notificationUrl, instanceTitle, ...props }) => {
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);
  const userInfo = user.current_user;
  const menuItems = user.user_dropdown?.[0]?.children;

  const userDropdownItems = useMemo(
    () =>
      (menuItems || []).map((item, index) =>
        item.type === 'divider' ? (
          <Divider component="li" key={index} />
        ) : (
          <DropdownItem
            ouiaId={`user-dropdown-item-${index}`}
            key={index}
            // keeps html_options (e.g. data-method="post" for Log Out) on the <a>
            component={createMenuLinkComponent(
              item.url,
              item.html_options,
              'user_menuitem'
            )}
          >
            {__(item.name)}
          </DropdownItem>
        )
      ),
    [menuItems]
  );

  return (
    userInfo && (
      <Dropdown
        ouiaId="user-info-dropdown"
        popperProps={{ position: 'right' }}
        onSelect={() => setUserDropdownOpen(false)}
        onOpenChange={isOpen => setUserDropdownOpen(isOpen)}
        isOpen={userDropdownOpen}
        toggle={toggleRef => (
          <MenuToggle
            ref={toggleRef}
            ouiaId="user-dropdown-toggle"
            variant="plainText"
            icon={<UserAltIcon />}
            isExpanded={userDropdownOpen}
            onClick={() => setUserDropdownOpen(!userDropdownOpen)}
          >
            {userInfo.name}
          </MenuToggle>
        )}
        {...props}
      >
        <DropdownList>{userDropdownItems}</DropdownList>
      </Dropdown>
    )
  );
};

UserDropdowns.propTypes = {
  /** Additional element css classes */
  className: PropTypes.string,
  /** User Data Array */
  user: userPropType,
  /** notification URL */
  notificationUrl: PropTypes.string,
  instanceTitle: PropTypes.string,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  notificationUrl: '',
  instanceTitle: '',
};
export default UserDropdowns;
