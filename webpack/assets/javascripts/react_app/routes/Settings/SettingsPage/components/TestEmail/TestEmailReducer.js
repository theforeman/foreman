import Immutable from 'seamless-immutable';

import { TEST_EMAIL_REQUEST, TEST_EMAIL_RESPONSE } from './TestEmailConstants';

export const initialState = Immutable({
  loading: false,
});

const reducer = (state = initialState, action) => {
  switch (action.type) {
    case TEST_EMAIL_REQUEST:
      return state.set('loading', true);
    case TEST_EMAIL_RESPONSE:
      return state.set('loading', false);
    default:
      return state;
  }
};

export default reducer;
