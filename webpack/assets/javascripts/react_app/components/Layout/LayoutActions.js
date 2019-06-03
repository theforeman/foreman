import { combineMenuItems } from './LayoutHelper';
import {
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_UPDATE_ITEMS,
  LAYOUT_CHANGE_LOCATION,
  LAYOUT_CHANGE_ACTIVE,
  LAYOUT_CHANGE_ORG,
  LAYOUT_EXPAND,
  LAYOUT_COLLAPSE,
} from './LayoutConstants';

export const showLoading = () => ({
  type: LAYOUT_SHOW_LOADING,
});

export const hideLoading = () => ({
  type: LAYOUT_HIDE_LOADING,
});

export const changeActiveMenu = ({ title }) => dispatch => {
  dispatch({
    type: LAYOUT_CHANGE_ACTIVE,
    payload: {
      activeMenu: title,
    },
  });
};

export const fetchMenuItems = data => dispatch => {
  const items = combineMenuItems(data);
  dispatch({
    type: LAYOUT_UPDATE_ITEMS,
    payload: {
      items,
    },
  });
};

export const changeOrganization = org => dispatch => {
  dispatch({
    type: LAYOUT_CHANGE_ORG,
    payload: { org },
  });
};

export const changeLocation = location => dispatch => {
  dispatch({
    type: LAYOUT_CHANGE_LOCATION,
    payload: {
      location,
    },
  });
};

export const onExpand = () => ({
  type: LAYOUT_EXPAND,
});

export const onCollapse = () => ({
  type: LAYOUT_COLLAPSE,
});
