import Immutable from 'seamless-immutable';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
} from './BreadcrumbBarConstants';

const initialState = Immutable({
  resourceSwitcherItems: [],
  isLoadingResources: false,
  isSwitcherOpen: false,
  resourceUrl: null,
  requestError: null,
  currentPage: null,
  pages: null,
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case BREADCRUMB_BAR_RESOURCES_REQUEST:
      return state
        .set('resourceSwitcherItems', [])
        .set('resourceUrl', payload.resourceUrl)
        .set('requestError', null)
        .set('isLoadingResources', true);

    case BREADCRUMB_BAR_RESOURCES_SUCCESS:
      return state
        .set('resourceSwitcherItems', payload.items)
        .set('resourceUrl', payload.resourceUrl)
        .set('currentPage', payload.page)
        .set('pages', payload.pages)
        .set('requestError', null)
        .set('isLoadingResources', false);

    case BREADCRUMB_BAR_RESOURCES_FAILURE:
      return state
        .set('resourceSwitcherItems', [])
        .set('requestError', payload.error)
        .set('resourceUrl', payload.resourceUrl)
        .set('isLoadingResources', false);

    case BREADCRUMB_BAR_TOGGLE_SWITCHER:
      return state.set('isSwitcherOpen', !state.isSwitcherOpen);

    case BREADCRUMB_BAR_CLOSE_SWITCHER:
      return state.set('isSwitcherOpen', false);

    default:
      return state;
  }
};
