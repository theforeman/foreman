import store from './react_app/redux';

import { notify, clear } from './foreman_toast_notifications';

jest.unmock('jquery');
jest.unmock('./foreman_toast_notifications');
jest.mock('@reduxjs/toolkit', () => ({
  ...jest.requireActual('@reduxjs/toolkit'),
  nanoid: jest.fn(() => 42)
}))

describe('Notifications', () => {
  describe('notify', () => {
    const testNotification = ({ notification, expected }) => {
      notify(notification);

      expect(store.dispatch).toHaveBeenCalledWith({payload: {key: 42, toast: expected}, type: 'toasts/addToast'});
    };

    beforeEach(() => {
      store.dispatch = jest.fn();
    });

    it('should dispatch a notification action without link', () => {
      const notification = { message: 'some message', type: 'some type' };
      const expected = { ...notification, sticky: true, link: undefined };

      testNotification({ notification, expected });
    });

    it('should dispatch a notification action with link', () => {
      const notification = {
        message: 'some message',
        type: 'some type',
        link: { href: '#', children: 'text' },
      };
      const expected = { ...notification, sticky: true };

      testNotification({ notification, expected });
    });

    it('should dispatch a none-sticky notification action when using success type', () => {
      const notification = { message: 'some message', type: 'success' };
      const expected = { ...notification, sticky: false, link: undefined };

      testNotification({ notification, expected });
    });

    it('should dispatch a sticky notification action when passing sticky=true', () => {
      const notification = {
        message: 'some message',
        type: 'success',
        sticky: true,
      };
      const expected = { ...notification, link: undefined };

      testNotification({ notification, expected });
    });

    it('should dispatch a none-sticky notification action when passing sticky=false', () => {
      const notification = {
        message: 'some message',
        type: 'some type',
        sticky: false,
      };
      const expected = { ...notification, link: undefined };

      testNotification({ notification, expected });
    });
  });

  describe('clear', () => {
    beforeEach(() => {
      store.dispatch = jest.fn();
    });

    it('should dispatch a clear notification action', () => {
      clear();

      expect(store.dispatch).toHaveBeenCalledWith({payload: undefined, type: 'toasts/clearToasts'});
    });
  });
});
