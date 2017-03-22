import React from 'react';
import { Dropdown, Glyphicon, MenuItem } from 'react-bootstrap';
import NotificationActions from '../../actions/NotificationActions';

const NotificationDropdown = ({ links, id }) => {
  const listLinks = links.map((link, i) => {
    const liKey = `notification-link-${i}-${id}`;
    const isExternalUrl = (link.href).includes(window.location.origin);

    return (
      <MenuItem key={liKey} id={liKey}
                target={isExternalUrl ? '_blank' : '_self'} href={link.href}
                onClick={() => isExternalUrl ?
                  'false' : NotificationActions.toggleNotificationDrawer()}>
        {link.title}
      </MenuItem>
    );
  });

  return (
    <Dropdown className="pull-right dropdown-kebab-pf" pullRight key={id}
              id={`notifications-dropdown-${id}`}>
      <Dropdown.Toggle noCaret bsStyle="link">
        <Glyphicon bsClass="fa" glyph="ellipsis-v" />
      </Dropdown.Toggle>
      <Dropdown.Menu>
        {listLinks}
      </Dropdown.Menu>
    </Dropdown>
  );
};

export default NotificationDropdown;
