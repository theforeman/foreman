import React from 'react';
import NotificationActions from '../../actions/NotificationActions';

const NotificationPanelHeading = ({group, unread, title}) => {
  const styles = {textTransform: 'capitalize'};

  function expandDrawerTab() {
    NotificationActions.expandDrawerTab(group);
  }

  return (
    <div className="panel-heading" onClick={expandDrawerTab}>
      <h4 className="panel-title">
        <a style={styles}>
          {title}
        </a>
      </h4>
      <span className="panel-counter">
        {unread} New {unread !== 1 ? 'Events' : 'Event'}
        </span>
    </div>
  );
};

export default NotificationPanelHeading;
