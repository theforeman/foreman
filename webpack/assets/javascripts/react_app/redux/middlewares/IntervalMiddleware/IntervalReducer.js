import Immutable from 'seamless-immutable';
import { START_INTERVAL, STOP_INTERVAL } from './IntervalConstants';

const initialState = Immutable({});

export const reducer = (state = initialState, action) => {
  const { type, key, intervalID } = action;
  switch (type) {
    case START_INTERVAL:
      return state.merge({ [key]: intervalID });
    case STOP_INTERVAL:
      return state.without(key);
    default:
      return state;
  }
};

export const reducers = { intervals: reducer };

export default reducer;
