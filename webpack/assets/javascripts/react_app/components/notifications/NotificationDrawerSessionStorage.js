import { getValue, setValue } from '../../common/SessionStorage';

export const getIsOpened = () => getValue('isDrawerOpen');
export const setIsOpened = (value) => setValue('isDrawerOpen', value);
export const getExpandedGroup = () => getValue('expandedGroup');
export const setExpandedGroup = (value) => setValue('expandedGroup', value);
export const getHasUnreadMessages = () => getValue('hasUnreadMessages');
export const setHasUnreadMessages = (value) =>
  setValue('hasUnreadMessages', value);
