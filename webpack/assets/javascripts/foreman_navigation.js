import store from './react_app/redux';
import * as LayoutActions from './react_app/components/Layout/LayoutActions';

export const showLoading = () => {
  store.dispatch(LayoutActions.showLoading());
};

export const hideLoading = () => {
  store.dispatch(LayoutActions.hideLoading());
};

export const changeLocation = loc => {
  store.dispatch(LayoutActions.changeLocation(loc));
};

export const changeOrganization = org => {
  store.dispatch(LayoutActions.changeOrganization(org));
};

export const changeActive = active => {
  store.dispatch(LayoutActions.changeActiveMenu({ title: active }));
};

export function showContent(layout, unsubscribe) {
  const content = () => {
    $('#content').show();
    unsubscribe();
  };
  // workaround for pages with no layout object
  if (layout.items.length && !layout.isLoading) {
    content();
  } else if ($('#layout').length === 0) content();
}
