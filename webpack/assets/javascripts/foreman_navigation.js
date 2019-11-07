import $ from 'jquery';
import { contentSwaping } from './services/InternalAjax';
import store from './react_app/redux';
import * as LayoutActions from './react_app/components/Layout/LayoutActions';
import { deprecateObjectProperty } from './foreman_tools';

export const ApplyLinks = () => {
  const anchorTags = document.querySelectorAll('a[data-ajax-loading]');
  anchorTags.forEach(elem => {
    elem.onclick = () => {
      const { text, href } = elem;
      visit(text, href);
      return false;
    };
  });
};

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

export const visit = (url, name = null) => {
  window.history.pushState({}, name || url, url);
  contentSwaping(url);
};

window.Turbolinks = { visit };
// eslint-disable-next-line no-undef
deprecateObjectProperty(Turbolinks, 'visit', 'tfm.nav.visit');
