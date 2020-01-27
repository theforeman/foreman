/* eslint-disable jquery/no-show */

import $ from 'jquery';
import { push } from 'connected-react-router';
import store from './react_app/redux';
import * as LayoutActions from './react_app/components/Layout/LayoutActions';
import * as AppActions from './react_app/ReactApp/ReactAppActions';
import { deprecate } from './react_app/common/DeprecationService';
import { urlWithQueryParams } from './react_app/common/urlHelpers';
import { inBlackList } from './react_app/components/Legacy/BackList';

export const initClicks = () => {
  $('#content')
    .off()
    // eslint-disable-next-line func-names
    .on('click', 'a', function(e) {
      const href = this.getAttribute('href');
      if (inBlackList(href)) return;
      e.preventDefault();
      if (this.getAttribute('href').startsWith('/')) {
        pushUrl(this.getAttribute('href'));
      }
    });
};

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

/**
 * Build a url with query params
 * @param {String} url - the base url i.e `/hosts`
 * @param {Object} searchQuery - the query params, i.e {'per_page': 4, 'page': 2}
 */

export const pushUrl = (url, queryParams) => {
  const newUrl = urlWithQueryParams(url, queryParams);
  return store.dispatch(push(newUrl));
};

export const updateLegacyLoading = status => {
  store.dispatch(AppActions.updateLegacyLoading(status));
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
