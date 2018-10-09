import { flatten, get } from 'lodash';
import API from '../../API';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
  BREADCRUMB_BAR_CLEAR_SEARCH,
  BREADCRUMB_BAR_UPDATE_TITLE,
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

export const updateBreadcrumbTitle = title => ({
  type: BREADCRUMB_BAR_UPDATE_TITLE,
  payload: title,
});

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
    const switcherItems = flatten(Object.values(data.results)).map(result => {
      const itemName = get(result, nameField);
      return {
        name: itemName,
        id: result.id,
        url: switcherItemUrl
          .replace(':id', result.id)
          .replace(':name', itemName),
      };
    });

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
    {
      page,
      per_page: 10,
      search: createSearch(nameField, searchQuery, resource.resourceFilter),
    }
  ).then(onRequestSuccess, onRequestFail);
};

export const createSearch = (nameField, searchQuery, resourceFilter) => {
  let query = '';
  if (resourceFilter) {
    query += resourceFilter;
  }

  if (query && searchQuery) {
    query += ` AND ${simpleNameQuery(nameField, searchQuery)}`;
  } else {
    query += simpleNameQuery(nameField, searchQuery);
  }

  return query;
};

const simpleNameQuery = (nameField, searchQuery) =>
  searchQuery ? `${[nameField]}~${searchQuery}` : '';
