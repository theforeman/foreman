import React from 'react';
import { OverlayTrigger, Tooltip } from 'react-bootstrap';

export default ({ hsUnreadMessages, onClick }) => {
  const iconType = hsUnreadMessages ? 'fa-bell' : 'fa-bell-o';
  const tooltip = <Tooltip id="tooltip">Notifications</Tooltip>;

   return (
     <OverlayTrigger placement="bottom"
                     id="notifications-toggle-icon"
                     overlay={tooltip}>
        <span onClick={onClick}
              className={`fa ${iconType}`}
              aria-describedby="tooltip">
        </span>
     </OverlayTrigger>
   );
};
