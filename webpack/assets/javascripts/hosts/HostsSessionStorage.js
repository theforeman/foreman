import { getValue, setValue } from '../react_app/common/SessionStorage';

export const getHostQuery = () => getValue('hostQuery');
export const setHostQuery = (value) => setValue('hostQuery', value);
