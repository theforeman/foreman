import Immutable from 'seamless-immutable';

import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_EXPAND,
  LAYOUT_COLLAPSE,
} from './LayoutConstants';

const initialState = Immutable({
  items: [],
  isLoading: false,
  isCollapsed: false,
  activeMenu: 'initialActive',
});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case LAYOUT_INITIALIZE:
      return state
        .set('items', payload.items)
        .set('activeMenu', payload.activeMenu)
        .set('isCollapsed', payload.isCollapsed)
        .set('currentOrganization', payload.organization)
        .set('currentLocation', payload.location);

    case LAYOUT_SHOW_LOADING:
      return state.set('isLoading', true);

    case LAYOUT_HIDE_LOADING:
      return state.set('isLoading', false);

    case LAYOUT_CHANGE_ACTIVE:
      return state.set('activeMenu', payload.activeMenu);

    case LAYOUT_EXPAND:
      return state.set('isCollapsed', false);

    case LAYOUT_COLLAPSE:
      return state.set('isCollapsed', true);

    default:
      return state;
  }
};
