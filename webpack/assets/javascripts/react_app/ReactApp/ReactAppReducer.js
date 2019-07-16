import Immutable from 'seamless-immutable';

import { APP_FETCH_SERVER_PROPS, I18N_READY } from './ReactAppConstants';

const initialState = Immutable({
  metadata: {},
  i18nReady: false,
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case APP_FETCH_SERVER_PROPS:
      return state.set('metadata', payload);
    case I18N_READY:
      return state.set('i18nReady', true);
    default:
      return state;
  }
};
