import Immutable from 'seamless-immutable';
import { LOCATION_CHANGE } from 'connected-react-router';
import {
  APP_FETCH_SERVER_PROPS,
  UPDATE_LEGACY_LOADING_STATE,
} from './ReactAppConstants';

const initialState = Immutable({
  metadata: {},
  legacyLoading: false,
  // Private state's record, for current location please use `state.router.location`
  _currentHref: null,
  referer: null,
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case LOCATION_CHANGE:
      if (state._currentHref === window.location.href) return state;
      return state.merge({
        referer: state._currentHref,
        _currentHref: window.location.href,
        legacyLoading: true,
      });
    case UPDATE_LEGACY_LOADING_STATE:
      return state.set('legacyLoading', payload);
    case APP_FETCH_SERVER_PROPS:
      return state.set('metadata', payload);

    default:
      return state;
  }
};
