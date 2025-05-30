import PropTypes from 'prop-types';
import React, { useEffect, useState, useMemo } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { NotificationBadgeVariant as BadgeVariant } from '@patternfly/react-core';
import { groupBy } from 'lodash';
import { startNotificationsPolling } from '../../redux/actions/notifications';
import forceSingleton from '../../common/forceSingleton';

export const NotificationsContext = forceSingleton('NotificationsContext', () =>
  React.createContext({})
);

export const NotificationsContextWrapper = ({ children }) => {
  const dispatch = useDispatch();
  const drawerRef = React.useRef(null);

  const [isExpanded, setIsExpanded] = useState(false);
  const [variant, setVariant] = useState(BadgeVariant.read);

  const notificationsState = useSelector(state => state.notifications);
  const notifications = groupBy(notificationsState.notifications, n => n.group);

  const [expandedNotifications, setExpandedNotifications] = useState([]);
  const [expandedKebab, setExpandedKebab] = useState('');

  const isGroupExpanded = key => expandedNotifications.includes(key);
  const isKebabExpanded = key => expandedKebab === key;

  const toggleNotifications = key => {
    const otherExpanded = expandedNotifications.filter(
      arrKeys => arrKeys !== key
    );
    return isGroupExpanded(key)
      ? setExpandedNotifications(otherExpanded)
      : setExpandedNotifications([...otherExpanded, key]);
  };

  const toggleKebab = key => {
    isKebabExpanded(key) ? setExpandedKebab('') : setExpandedKebab(key);
  };

  const closeNotificationsDrawer = () => {
    toggleKebab('');
    toggleExpanded();
  };

  useEffect(() => {
    dispatch(startNotificationsPolling());
  }, [dispatch]);

  const countUnreadMessages = useMemo(() => {
    if (notificationsState.notifications) {
      const count = Object.values(notificationsState.notifications).filter(
        n => !n.seen
      ).length;

      setVariant(count > 0 ? BadgeVariant.unread : BadgeVariant.read);
      return count;
    }
    return 0;
  }, [notificationsState]);

  const toggleExpanded = () => {
    setIsExpanded(!isExpanded);
  };

  return (
    <NotificationsContext.Provider
      value={{
        isExpanded,
        setIsExpanded,
        toggleExpanded,
        variant,
        drawerRef,
        notifications,
        countUnreadMessages,
        dispatch,
        toggleKebab,
        isKebabExpanded,
        isGroupExpanded,
        closeNotificationsDrawer,
        toggleNotifications,
      }}
    >
      {children}
    </NotificationsContext.Provider>
  );
};

NotificationsContextWrapper.propTypes = {
  children: PropTypes.node.isRequired,
};
