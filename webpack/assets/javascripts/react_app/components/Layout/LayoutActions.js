import {
  LAYOUT_INITIALIZE,
  LAYOUT_SHOW_LOADING,
  LAYOUT_HIDE_LOADING,
} from './LayoutConstants';

export const initializeLayout = ({ items, organization, location }) => ({
  type: LAYOUT_INITIALIZE,
  payload: {
    items,
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
