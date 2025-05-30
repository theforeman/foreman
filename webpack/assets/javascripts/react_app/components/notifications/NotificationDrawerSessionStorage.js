import { getValue, setValue } from '../../common/SessionStorage';

export const getHasUnreadMessages = () => getValue('hasUnreadMessages');
export const setHasUnreadMessages = value =>
  setValue('hasUnreadMessages', value);
