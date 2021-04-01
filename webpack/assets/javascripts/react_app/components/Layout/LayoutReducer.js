import Immutable from 'seamless-immutable';

import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_IS_NAV_OPEN,
} from './LayoutConstants';

const initialState = Immutable({
  items: [],
  isLoading: false,
  isNavOpen: true,
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case LAYOUT_INITIALIZE:
      return state
        .set('items', payload.items)
        .set('isNavOpen', payload.isNavOpen)
        .set('currentOrganization', payload.organization)
        .set('currentLocation', payload.location);

    case LAYOUT_SHOW_LOADING:
      return state.set('isLoading', true);

    case LAYOUT_HIDE_LOADING:
      return state.set('isLoading', false);

    case LAYOUT_CHANGE_IS_NAV_OPEN:
      return state.set('isNavOpen', payload.isNavOpen);

    default:
      return state;
  }
};
