import Immutable from 'seamless-immutable';

import { APP_FETCH_SERVER_PROPS } from './ReactAppConstants';

const initialState = Immutable({
  metadata: {},
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case APP_FETCH_SERVER_PROPS:
      return state.set('metadata', payload);

    default:
      return state;
  }
};
