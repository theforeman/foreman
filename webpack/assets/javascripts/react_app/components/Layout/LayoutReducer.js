import Immutable from 'seamless-immutable';

import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_RESOURCES_REQUEST,
  LAYOUT_CHANGE_ORG,
  LAYOUT_CHANGE_LOCATION,
} from './LayoutConstants';

const initialState = Immutable({
  items: [],
  isLoading: false,
  activeMenu: '',
  currentOrg: 'Any Organization',
  currentLoc: 'Any Location',
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case LAYOUT_SHOW_LOADING:
      return state.set('isLoading', true);

    case LAYOUT_HIDE_LOADING:
      return state.set('isLoading', false);

    case LAYOUT_CHANGE_ACTIVE:
      if (state.items.length > 0) {
        return state.set(
          'items',
          state.items.map((item) => {
            if (item.title === payload.primary.title) {
              return item.set('initialActive', true);
            }
            return item.set('initialActive', false);
          }),
        );
      }
      return state;

    case LAYOUT_RESOURCES_REQUEST:
      if (state.items.length === 0) {
        return state.set('items', payload.items);
      }
      return state;

    case LAYOUT_CHANGE_ORG:
      return state.set('currentOrg', payload.org);

    case LAYOUT_CHANGE_LOCATION:
      return state.set('currentLoc', payload.location);

    default:
      return state;
  }
};
