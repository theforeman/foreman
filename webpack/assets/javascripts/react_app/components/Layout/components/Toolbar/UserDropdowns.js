import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Dropdown,
  DropdownToggle,
  DropdownItem,
  DropdownSeparator,
} from '@patternfly/react-core';
import { UserAltIcon } from '@patternfly/react-icons';

import { userPropType } from '../../LayoutHelper';
import { translate as __ } from '../../../../common/I18n';

const UserDropdowns = ({
  user,
  changeActiveMenu,
  notificationUrl,
  instanceTitle,
  ...props
}) => {
  const [userDropdownOpen, setUserDropdownOpen] = useState(false);

  const onDropdownToggle = (newUserDropdownOpen) => {
    setUserDropdownOpen(newUserDropdownOpen);
  };
  const onDropdownSelect = () => {
    setUserDropdownOpen(userDropdownOpen);
  };
  const userInfo = user.current_user;

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
    userInfo && (
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
  /** changeActiveMenu Func */
  changeActiveMenu: PropTypes.func,
  instanceTitle: PropTypes.string,
};
UserDropdowns.defaultProps = {
  className: '',
  user: {},
  notificationUrl: '',
  changeActiveMenu: null,
  instanceTitle: '',
};
export default UserDropdowns;
