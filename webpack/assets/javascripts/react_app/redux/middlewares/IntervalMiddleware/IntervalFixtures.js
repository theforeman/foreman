import { noop } from '../../../common/helpers';

export const key = 'SOME_KEY';
export const method = noop;
export const interval = 3000;
export const intervalID = 1212;
export const initialState = {};
export const stateWithKey = { [key]: intervalID };
