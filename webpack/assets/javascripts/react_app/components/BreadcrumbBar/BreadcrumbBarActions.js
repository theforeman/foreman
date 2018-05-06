import { flatten, get } from 'lodash';
import API from '../../API';

import {
  BREADCRUMB_BAR_TOGGLE_SWITCHER,
  BREADCRUMB_BAR_CLOSE_SWITCHER,
  BREADCRUMB_BAR_RESOURCES_REQUEST,
  BREADCRUMB_BAR_RESOURCES_SUCCESS,
  BREADCRUMB_BAR_RESOURCES_FAILURE,
} from './BreadcrumbBarConstants';

export const toggleSwitcher = () => ({
  type: BREADCRUMB_BAR_TOGGLE_SWITCHER,
});

export const closeSwitcher = () => ({
  type: BREADCRUMB_BAR_CLOSE_SWITCHER,
});

export const loadSwitcherResourcesByResource = (resource, options = {}) => (dispatch) => {
  const { resourceUrl, nameField, switcherItemUrl } = resource;
  const { page = 1 } = options;

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
    dispatch({ type: BREADCRUMB_BAR_RESOURCES_FAILURE, payload: { error, resourceUrl } });

  const formatResults = ({ data }) => {
    const switcherItems = flatten(Object.values(data.results)).map(result => ({
      name: get(result, nameField),
      id: result.id,
      url: switcherItemUrl.replace(':id', result.id),
    }));

    return {
      items: switcherItems,
      page: Number(data.page),
      pages: Number(data.total) / Number(data.per_page),
    };
  };
  beforeRequest();

  return API.get(resourceUrl, {}, { page }).then(onRequestSuccess, onRequestFail);
};
