import Immutable from 'seamless-immutable';
import { noop } from '../../common/helpers';

export const key = 'SOME_KEY';
export const APIRequest = noop;
export const polling = 3000;
export const initialState = Immutable({
  polling: {},
});
export const stateWithKey = Immutable({
  polling: {
    [key]: 1,
  },
});
