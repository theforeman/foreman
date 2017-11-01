import React from 'react';
import { DropdownKebab, MenuItem } from 'patternfly-react';

const NotificationDropdown = ({ links, id, onClickedLink }) => {
  return (
    <DropdownKebab pullRight id={id}>
      {links.map((link, i) => (
        <MenuItem
          key={i}
          id={`notification-kebab-${i}`}
          onClick={onClickedLink.bind(this, link)}
        >
          {link.title}
        </MenuItem>
      ))}
    </DropdownKebab>
  );
};

export default NotificationDropdown;
