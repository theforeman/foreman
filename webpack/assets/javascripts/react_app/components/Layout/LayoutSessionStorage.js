import { getValue, setValue } from '../../common/SessionStorage';

export const getIsNavbarOpen = () => !!getValue('navOpen');

export const setIsNavbarOpen = value => setValue('navOpen', value);
