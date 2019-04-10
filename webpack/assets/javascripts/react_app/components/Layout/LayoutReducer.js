import Immutable from 'seamless-immutable';

import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_UPDATE_ITEMS,
  LAYOUT_CHANGE_ORG,
  LAYOUT_CHANGE_LOCATION,
  LAYOUT_CHANGE_ACTIVE,
} from './LayoutConstants';

const initialState = Immutable({
  items: [],
  isLoading: false,
  activeMenu: 'initialActive',
  currentOrganization: { title: 'Any Organization' },
  currentLocation: { title: 'Any Location' },
});

export default (state = initialState, action) => {
  const { payload: { items, activeMenu, org, location } = {}, type } = action;

  switch (type) {
    case LAYOUT_SHOW_LOADING:
      return state.set('isLoading', true);

    case LAYOUT_HIDE_LOADING:
      return state.set('isLoading', false);

    case LAYOUT_UPDATE_ITEMS:
      return state.set('items', items);

    case LAYOUT_CHANGE_ORG:
      return state.set('currentOrganization', org);

    case LAYOUT_CHANGE_LOCATION:
      return state.set('currentLocation', location);

    case LAYOUT_CHANGE_ACTIVE:
      return state.set('activeMenu', activeMenu);

    default:
      return state;
  }
};
