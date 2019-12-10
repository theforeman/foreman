/* eslint-disable jquery/no-show */

import $ from 'jquery';
import store from './react_app/redux';
import * as LayoutActions from './react_app/components/Layout/LayoutActions';
import { deprecate } from './react_app/common/DeprecationService';

window.Turbolinks = {
  visit: url => {
    deprecate(
      'Turbolinks.visit',
      'react router or visit(<url>) method, or legacy tfm.nav.visit(<url>)',
      '2.1'
    );
    visit(url);
  },
};

export const visit = url => {
  window.location.href = url;
};

export const reloadPage = () => {
  window.location.reload();
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
