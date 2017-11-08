import React from 'react';
import Notification from './notification';

export default ({
  group,
  notifications,
  isExpanded,
  onExpand,
  onMarkAsRead,
  onMarkGroupAsRead,
  onClickedLink,
}) => {
  const className = `panel panel-default ${isExpanded ? 'expanded' : ''}`;
  const unreadCount = notifications.filter(notification => !notification.seen)
    .length;

  return (
    <div className={className}>
      <div className="panel-heading" onClick={() => onExpand(group)}>
        <h4 className="panel-title">
          <a className={isExpanded ? '' : 'collapsed'}>{group}</a>
        </h4>
        <span className="panel-counter">
          {`${unreadCount} ${
            unreadCount !== 1 ? __('New Events') : __('New Event')
          }`}
        </span>
      </div>
      {isExpanded && (
        <div className="panel-body">
          {notifications.map(notification => (
            <Notification
              onClickedLink={onClickedLink}
              key={notification.id}
              notification={notification}
              onMarkAsRead={onMarkAsRead.bind(this, group)}
            />
          ))}
          <div className="drawer-pf-action">
            <a
              className="btn btn-link btn-block"
              onClick={onMarkGroupAsRead.bind(this, group)}
              disabled={unreadCount === 0}
            >
              {__('Mark All Read')}
            </a>
          </div>
        </div>
      )}
    </div>
  );
};
