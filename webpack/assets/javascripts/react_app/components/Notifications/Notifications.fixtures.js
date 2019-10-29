/* eslint-disable camelcase */
/* eslint-disable camelcase */
import Immutable from 'seamless-immutable';

export const initialState = Immutable({
  expandedGroup: null,
  isDrawerOpen: null,
  hasUnreadMessages: false,
});

export const panelRequest = {
  group: 'Hosts',
};
export const NotificationRequest = {
  id: 51435,
};

export const notifications = [
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
];

export const stateWithNotifications = Immutable({
  isDrawerOpen: true,
  expandedGroup: 'Hosts',
  hasUnreadMessages: true,
  notifications,
});

export const componentMountData = { url: '/notification_recipients' };

export const serverResponse = `{"data": { "notifications":[
  {"id":1,"seen":true,"level":"info","text":"notification1","created_at":"2017-02-23T05:00:28.715Z",
  "group":"React devs","actions":{}},
  {"id":2,"seen":false,"level":"info","text":"notification2","created_at":"2017-02-23T05:00:28.715Z",
  "group":"React devs","actions":{}}]}}`;
