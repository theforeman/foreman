import Immutable from 'seamless-immutable';
import { DEBOUNCE_START, DEBOUNCE_CLEAR } from './DebounceConstants';

const initialState = Immutable({});

export const reducer = (state = initialState, action) => {
  const { type, payload: { key, debounceID } = {} } = action;
  switch (type) {
    case DEBOUNCE_START:
      return state.merge({ [key]: debounceID });
    case DEBOUNCE_CLEAR:
      return state.without(key);
    default:
      return state;
  }
};

export const reducers = { debounce: reducer };

export default reducer;
