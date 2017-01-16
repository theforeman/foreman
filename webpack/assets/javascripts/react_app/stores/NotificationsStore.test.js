jest.unmock('./NotificationsStore');
jest.unmock('../constants');
jest.unmock('../dispatcher');
jest.unmock('../actions/ServerActions');

import NotificationsStore from './NotificationsStore';
import data from './NotificationsTestData';

describe('NotificationsStore', () => {
  it('builds data structure', () => {
    const result = NotificationsStore.prepareNotifications(data);

    expect(Object.keys(result).length).toBe(4);
    expect(result.test.length).toBe(2);
    expect(result.info.length).toBe(2);
    expect(result.error.length).toBe(1);
    expect(result.warning.length).toBe(1);
  });

  it('sorts groups by date descending', () => {
    const result = NotificationsStore.prepareNotifications(data);

    expect(result.test[0].id).toBe(6);
    expect(result.test[1].id).toBe(3);
    expect(result.info[0].id).toBe(18);
    expect(result.info[1].id).toBe(9);
  });
});
