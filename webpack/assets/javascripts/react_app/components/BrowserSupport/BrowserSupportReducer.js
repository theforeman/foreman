import Immutable from 'seamless-immutable';

import {
  BROWSER_SUPPORT_INITIALIZE,
  BROWSER_SUPPORT_SHOW_BANNER,
} from './BrowserSupportConstants';

const initialState = Immutable({
  show: false,
  browserName: '',
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case BROWSER_SUPPORT_INITIALIZE:
      return state.merge(payload);
    case BROWSER_SUPPORT_SHOW_BANNER:
      return state.set('show', true);
    default:
      return state;
  };
}
