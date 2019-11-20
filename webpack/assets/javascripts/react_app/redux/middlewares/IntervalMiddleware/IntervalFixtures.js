const type = 'SOME_TYPE';
const payload = { test: true };
export const key = 'SOME_KEY';
export const interval = 3000;
export const intervalID = 1212;
export const initialState = {};
export const stateWithKey = { [key]: intervalID };
export const actionWithInterval = { type, key, interval, payload };
