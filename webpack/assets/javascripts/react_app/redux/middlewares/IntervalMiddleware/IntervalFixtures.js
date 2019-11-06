import { noop } from '../../../common/helpers';

export const key = 'SOME_KEY';
export const callback = noop;
export const args = [];
export const interval = 3000;
export const intervalID = 1212;
export const initialState = {};
export const stateWithKey = { [key]: intervalID };
export const fakeStore = {
  getState: () => ({
    intervals: initialState,
  }),
};
export const fakeStoreWithKey = {
  getState: () => ({
    intervals: stateWithKey,
  }),
};
