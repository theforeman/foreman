import { flatten, get } from 'lodash';
import { translate as __ } from '../../common/I18n';
import { API_OPERATIONS } from '../../redux/API';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_CLEAR_SEARCH,
  BREADCRUMB_BAR_UPDATE_TITLE,
  BREADCRUMB_BAR_RESOURCES,
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
) => async dispatch => {
  const { resourceUrl, nameField, switcherItemUrl } = resource;
  const formatResults = data => {
    const switcherItems = flatten(Object.values(data.results)).map(result => {
      const itemName = get(result, nameField);
      return {
        name: __(itemName),
        id: result.id,
        href: switcherItemUrl
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

  dispatch({
    type: API_OPERATIONS.GET,
    key: BREADCRUMB_BAR_RESOURCES,
    url: resourceUrl,
    payload: {
      params: {
        page,
        per_page: 10,
        search: createSearch(nameField, searchQuery, resource.resourceFilter),
      },
      searchQuery,
      resourceUrl,
    },
    successFormat: formatResults,
  });
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
