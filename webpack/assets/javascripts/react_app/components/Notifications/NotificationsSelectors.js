import { groupBy } from 'lodash';

export const selectNotificationsNamespace = state => state.notifications;
export const selectIsDrawerOpen = state =>
  selectNotificationsNamespace(state).isDrawerOpen;
export const selectExpandedGroup = state =>
  selectNotificationsNamespace(state).expandedGroup;
export const selectHasUnreadMessages = state =>
  selectNotificationsNamespace(state).hasUnreadMessages;
export const selectNotifications = state => {
  const { notifications } = selectNotificationsNamespace(state);
  return groupBy(notifications, n => n.group);
};
export const selectIsReady = state => !!selectNotifications(state);
