/* eslint-disable camelcase */
import immutable from 'seamless-immutable';

export const componentMountData = { url: '/notification_recipients' };

export const emptyState = immutable({
  notifications: {},
});

export const stateWithoutNotifications = immutable({
  notifications: {
    expandedGroup: 'React devs2',
    isDrawerOpen: true,
  },
});

export const stateWithNotifications = immutable({
  notifications: {
    expandedGroup: 'React devs2',
    isDrawerOpen: true,
    notifications: {
      '1': {
        id: 1,
        seen: true,
        level: 'info',
        text: null,
        created_at: '2017-02-23T05:00:28.715Z',
        group: 'React devs',
        actions: {},
      },
      '6': {
        id: 6,
        seen: true,
        level: 'info',
        text: 'Hi! This is a notification message',
        created_at: '2017-03-14T11:25:07.138Z',
        group: 'React devs2',
        actions: {
          links: [
            {
              href: 'https://theforeman.org/blog',
              title: 'Link to blog',
            },
          ],
        },
      },
    },
    hasUnreadMessages: true,
  },
});

export const stateWithUnreadNotifications = immutable({
  notifications: {
    expandedGroup: 'React devs2',
    isDrawerOpen: true,
    notifications: {
      '1': {
        id: 1,
        seen: true,
        level: 'info',
        text: null,
        created_at: '2017-02-23T05:00:28.715Z',
        group: 'React devs',
        actions: {},
      },
      '6': {
        id: 6,
        seen: false,
        level: 'info',
        text: 'Hi! This is a notification message',
        created_at: '2017-03-14T11:25:07.138Z',
        group: 'React devs2',
        actions: {
          links: [
            {
              href: 'https://theforeman.org/blog',
              title: 'Link to blog',
            },
          ],
        },
      },
    },
    hasUnreadMessages: true,
  },
});

export const serverResponse = `{ "notifications":[
  {"id":1,"seen":true,"level":"info","text":null,"created_at":"2017-02-23T05:00:28.715Z",
  "group":"React devs","actions":{}},
  {"id":2,"seen":false,"level":"info","text":null,"created_at":"2017-02-23T05:00:28.715Z",
  "group":"React devs","actions":{}}]}`;

export const emptyHtml =
  '<div id="notifications_container">' +
  '<span class="fa fa-bell-o" aria-describedby="tooltip">' +
  '</span></div>';
