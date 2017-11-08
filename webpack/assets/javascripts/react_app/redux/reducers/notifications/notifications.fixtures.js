/* eslint-disable camelcase */
/* eslint-disable camelcase */
import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  expandedGroup: null,
  isDrawerOpen: null,
  isPolling: false,
  hasUnreadMessages: false,
});

export const stateWithNotifications = Immutable({
  isDrawerOpen: true,
  expandedGroup: 'Hosts',
  hasUnreadMessages: true,
  notifications: [
    {
      id: 52435,
      seen: false,
      level: 'info',
      text: 'some.example.com has been deleted successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Hosts',
      actions: {},
    },
    {
      id: 51435,
      seen: false,
      level: 'info',
      text: 'notified successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Hosts',
      actions: {},
    },
    {
      id: 52433,
      seen: false,
      level: 'info',
      text: 'notfied successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Testing',
      actions: {},
    },
  ],
});
export const request = {
  group: 'Hosts',
};
export const response = Immutable({
  isDrawerOpen: true,
  expandedGroup: 'Hosts',
  hasUnreadMessages: true,
  notifications: [
    {
      id: 52435,
      seen: true,
      level: 'info',
      text: 'some.example.com has been deleted successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Hosts',
      actions: {},
    },
    {
      id: 51435,
      seen: true,
      level: 'info',
      text: 'notified successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Hosts',
      actions: {},
    },
    {
      id: 52433,
      seen: false,
      level: 'info',
      text: 'notfied successfully',
      created_at: '2017-04-17T17:29:12.664Z',
      group: 'Testing',
      actions: {},
    },
  ],
});
