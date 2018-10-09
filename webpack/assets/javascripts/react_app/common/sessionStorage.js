if (!window.sessionStorage) {
  window.sessionStorage = {
    getItem: () => {},
    setItem: () => {},
  };
}

const getValue = key => {
  const value = window.sessionStorage.getItem(key) || 'null';

  return JSON.parse(value);
};

const setValue = (key, value) =>
  window.sessionStorage.setItem(key, JSON.stringify(value));

export const notificationsDrawer = {
  getIsOpened: () => getValue('isDrawerOpen'),
  setIsOpened: value => setValue('isDrawerOpen', value),
  getExpandedGroup: () => getValue('expandedGroup'),
  setExpandedGroup: value => setValue('expandedGroup', value),
  getHasUnreadMessages: () => getValue('hasUnreadMessages'),
  setHasUnreadMessages: value => setValue('hasUnreadMessages', value),
};
