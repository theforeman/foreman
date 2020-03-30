import { DEFAULT_DEBOUNCE } from './DebounceConstants';
import { withDebounce } from './DebounceHelpers';

export const type = 'SOME_TYPE';
export const key = 'SOME_KEY';
export const payload = { test: true };
export const debounce = DEFAULT_DEBOUNCE;
export const debounceID = 121;
export const initialState = {};
export const stateWithKey = { [key]: debounceID };
export const action = { type, key, payload };
export const actionWithDebounce = withDebounce(action);
