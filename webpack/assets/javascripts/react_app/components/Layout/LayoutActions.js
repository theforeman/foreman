import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
  LAYOUT_EXPAND,
  LAYOUT_COLLAPSE,
} from './LayoutConstants';

export const initializeLayout = ({
  items,
  isCollapsed,
  organization,
  location,
}) => ({
  type: LAYOUT_INITIALIZE,
  payload: {
    items,
    isCollapsed,
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

export const expandLayoutMenus = () => ({
  type: LAYOUT_EXPAND,
});

export const collapseLayoutMenus = () => ({
  type: LAYOUT_COLLAPSE,
});
