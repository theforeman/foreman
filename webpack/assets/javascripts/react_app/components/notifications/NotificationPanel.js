import React from 'react';
import NotificationPanelHeading from './NotificationPanelHeading';
import NotificationPanelBody from './NotificationPanelBody';

const NotificationPanel = ({notifications, title, id, expandedGroup}) => {
    let unread;

    if (notifications) {
      unread = notifications.reduce((total, curr) => {
        if (!curr.seen) {
          total = total + 1;
        }
        return total;
      }, 0);
    } else {
      unread = 0;
    }
    const className = `panel panel-default ${expandedGroup === id ?
      'expanded' :
      ''}`;

    return (
      <div className={ className }>
        <NotificationPanelHeading title={title} group={id} unread={unread}/>
        <NotificationPanelBody notifications={notifications}
                               group={id} expandedGroup={expandedGroup}/>
      </div>
    );
  };

export default NotificationPanel;

