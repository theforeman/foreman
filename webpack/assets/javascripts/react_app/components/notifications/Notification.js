import React from 'react';
import Icon from '../common/Icon';
import moment from 'moment';
import NotificationActions from '../../actions/NotificationActions';
import '../../common/commonStyles.css';

/* eslint-disable camelcase */
const Notification = ({created_at, seen, text, level, id}) => {
  const created = moment(created_at);
  const title = __('Click to mark as read').toString();
  const tooltip = {
    title: title,
    'data-toggle': 'tooltip',
    'data-placement': 'top'
  };
  const markup = seen ?
    (<span className="drawer-pf-notification-message">{text}</span>) :
    (<strong {...tooltip} className="drawer-pf-notification-message pointer"
             onClick={markAsRead}>{text}</strong>);

  function markAsRead() {
    NotificationActions.markAsRead('/notification_recipients/' + id);
  }

  window.tfm.tools.activateTooltips();

  return (
    <div className="drawer-pf-notification">
      <Icon type={level} css="pull-left"></Icon>
      {markup}
      <div className="drawer-pf-notification-info">
        <span className="date">{created.format('M/D/YY')}</span>
        <span className="time">{created.format('hh:mm:ss A')}</span>
      </div>
    </div>
  );
};

export default Notification;
