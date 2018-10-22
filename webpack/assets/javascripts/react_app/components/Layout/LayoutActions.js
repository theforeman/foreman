
import { combineMenuItems } from './LayoutHelper';
import { selectMenuItems } from './LayoutSelectors';
import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_UPDATE_ITEMS,
  LAYOUT_CHANGE_LOCATION,
  LAYOUT_CHANGE_ORG,
} from './LayoutConstants';

export const showLoading = () => ({
  type: LAYOUT_SHOW_LOADING,
});

export const hideLoading = () => ({
  type: LAYOUT_HIDE_LOADING,
});

export const changeActiveMenu = primary => (dispatch, getState) => {
  const items = selectMenuItems(getState()).map(item =>
    (primary.title === item.name ? { ...item, active: true } : { ...item, active: false }));

  dispatch({
    type: LAYOUT_UPDATE_ITEMS,
    payload: {
      items,
      activeMenu: primary.title,
    },
  });
};

export const fetchMenuItems = data => (dispatch) => {
  const items = combineMenuItems(data);
  dispatch({
    type: LAYOUT_UPDATE_ITEMS,
    payload: {
      items,
    },
  });
};

export const changeOrganization = org => (dispatch) => {
  dispatch({
    type: LAYOUT_CHANGE_ORG,
    payload: { org },
  });
};

export const changeLocation = location => (dispatch) => {
  dispatch({
    type: LAYOUT_CHANGE_LOCATION,
    payload: {
      location,
    },
  });
};
