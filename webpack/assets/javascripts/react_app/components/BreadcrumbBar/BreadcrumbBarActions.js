import { flatten, get } from 'lodash';
import API from '../../API';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
  BREADCRUMB_BAR_CLEAR_SEARCH,
} from './BreadcrumbBarConstants';

export const toggleSwitcher = () => ({
  type: BREADCRUMB_BAR_TOGGLE_SWITCHER,
});

export const closeSwitcher = () => ({
  type: BREADCRUMB_BAR_CLOSE_SWITCHER,
});

export const removeSearchQuery = resource => dispatch => {
  dispatch({
    type: BREADCRUMB_BAR_CLEAR_SEARCH,
  });
  loadSwitcherResourcesByResource(resource)(dispatch);
};

export const loadSwitcherResourcesByResource = (
  resource,
  { page = 1, searchQuery = '' } = {}
) => dispatch => {
  const { resourceUrl, nameField, switcherItemUrl } = resource;
  const options = { page, searchQuery };
  const beforeRequest = () =>
    dispatch({
      type: BREADCRUMB_BAR_RESOURCES_REQUEST,
      payload: { resourceUrl, options },
    });

  const onRequestSuccess = response =>
    dispatch({
      type: BREADCRUMB_BAR_RESOURCES_SUCCESS,
      payload: { ...formatResults(response), resourceUrl },
    });

  const onRequestFail = error =>
    dispatch({
      type: BREADCRUMB_BAR_RESOURCES_FAILURE,
      payload: { error, resourceUrl },
    });

  const formatResults = ({ data }) => {
    const switcherItems = flatten(Object.values(data.results)).map(result => ({
      name: get(result, nameField),
      id: result.id,
      url: switcherItemUrl.replace(':id', result.id),
    }));

    return {
      items: switcherItems,
      page: Number(data.page),
      pages: Number(data.subtotal) / Number(data.per_page),
    };
  };
  beforeRequest();

  return API.get(
    resourceUrl,
    {},
    { page, search: searchQuery && `${[nameField]}~${searchQuery}` }
  ).then(onRequestSuccess, onRequestFail);
};
