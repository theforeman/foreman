import Immutable from 'seamless-immutable';

import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
} from './LayoutConstants';

const initialState = Immutable({
  items: [],
  isLoading: false,
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case LAYOUT_INITIALIZE:
      return state
        .set('items', payload.items)
        .set('currentOrganization', payload.organization)
        .set('currentLocation', payload.location);

    case LAYOUT_SHOW_LOADING:
      return state.set('isLoading', true);

    case LAYOUT_HIDE_LOADING:
      return state.set('isLoading', false);

    default:
      return state;
  }
};
