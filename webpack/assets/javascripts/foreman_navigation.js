/* eslint-disable jquery/no-show */

import $ from 'jquery';
import URI from 'urijs';
import { push } from 'connected-react-router';
import store from './react_app/redux';
import * as LayoutActions from './react_app/components/Layout/LayoutActions';

export const visit = url => {
  window.location.href = url;
};

export const reloadPage = () => {
  window.location.reload();
};

/**
 * Push a new url to foreman's react router
 * @param {String} url - the base url i.e `/hosts`
 * @param {Object} searchQuery - the query params, i.e {'per_page': 4, 'page': 2}
 */
export const pushUrl = (url, queryParams = {}) => {
  const urlWithQueries = new URI(url).search(queryParams).toString();
  return store.dispatch(push(urlWithQueries));
};

export const showLoading = () => {
  store.dispatch(LayoutActions.showLoading());
};

export const hideLoading = () => {
  store.dispatch(LayoutActions.hideLoading());
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
