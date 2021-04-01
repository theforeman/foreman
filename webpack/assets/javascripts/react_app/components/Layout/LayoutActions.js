import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_CHANGE_IS_NAV_OPEN,
} from './LayoutConstants';

import { setIsNavbarOpen } from './LayoutSessionStorage';

export const initializeLayout = ({
  items,
  isNavOpen,
  organization,
  location,
}) => ({
  type: LAYOUT_INITIALIZE,
  payload: {
    items,
    isNavOpen,
    organization,
    location,
  },
});

export const showLoading = () => ({
  type: LAYOUT_SHOW_LOADING,
});

export const hideLoading = () => ({
  type: LAYOUT_HIDE_LOADING,
});

export const changeIsNavOpen = isNavOpen => {
  setIsNavbarOpen(isNavOpen);
  return {
    type: LAYOUT_CHANGE_IS_NAV_OPEN,
    payload: {
      isNavOpen,
    },
  };
};
