import { useState } from 'react';
import URI from 'urijs';
import { useHistory } from 'react-router-dom';
import { useAPI } from '../../../../common/hooks/API/APIHooks';

/**

A hook that encapsulates the logic for fetching the API response for TableIndexPage and HostsIndexPage
@param {Object}{replacementResponse} - If included, skip the API request and use this response instead
@param {string}{apiUrl} - url for the API to make requests to
@param {Object}{apiOptions} - options object. Should include { key: HOSTS_API_KEY }; see APIRequest.js for more details
@param {Object}{defaultParams} - 'params' object to send to useAPI
@return {Object} - returns the API response

*/

export const useTableIndexAPIResponse = ({
  replacementResponse,
  apiUrl,
  apiOptions = {},
  defaultParams = {},
  method = 'get',
}) => {
  let response = useAPI(
    replacementResponse ? null : method,
    apiUrl.includes('include_permissions')
      ? apiUrl
      : `${apiUrl}?include_permissions=true`,
    {
      ...apiOptions,
      params: defaultParams,
    }
  );

  if (replacementResponse) {
    response = replacementResponse;
  }

  return response;
};

/**
A hook that stores the 'params' state and returns the setParamsAndAPI and setSearch functions for TableIndexPage and HostsIndexPage
@param {Object}{defaultParams} - initial state value for params
@param {Object}{apiOptions} - options object. Should include { key: HOSTS_API_KEY }; see APIRequest.js for more details
@param {Function}{setAPIOptions} - Pass in the setAPIOptions function returned from useAPI.
@param {Function}{updateSearchQuery} - Pass in the updateSearchQuery function returned from useBulkSelect.
@param {Boolean}{pushToHistory} - If true, keep the browser url params in sync with search and pagination
@return {Object} - returns the setParamsAndAPI and setSearch functions, and current params
@return {Function}{setParamsAndAPI} - function to set the params and API options
@return {Function}{setSearch} - function to set the search query
@return {Object}{params} - current params state
*/
export const useSetParamsAndApiAndSearch = ({
  defaultParams,
  apiOptions,
  setAPIOptions,
  updateSearchQuery,
  pushToHistory = true,
}) => {
  const [params, setParams] = useState(defaultParams);
  const history = useHistory();
  const setParamsAndAPI = newParams => {
    // add url edit params to the new params
    if (pushToHistory) {
      const uri = new URI();
      uri.setSearch(newParams);
      history.push({ search: uri.search() });
    }
    setParams(newParams);
    setAPIOptions({ ...apiOptions, params: newParams });
  };

  const setSearch = newSearch => {
    if (pushToHistory) {
      const uri = new URI();
      uri.setSearch(newSearch);
      history.push({ search: uri.search() });
    }
    updateSearchQuery(newSearch.search);
    setParamsAndAPI({ ...params, ...newSearch });
  };

  return {
    setParamsAndAPI,
    setSearch,
    params,
  };
};

/**
 * A hook that fetches the current user's preferences for which columns to display in a table
 * @param  {string} tableName the name of the table, such as 'hosts'
 * @return {object} returns the current user's id and the columns
 */
export const useCurrentUserTablePreferences = ({ tableName }) => {
  const currentUserResponse = useAPI('get', '/api/v2/current_user');
  const currentUserId = currentUserResponse.response?.id;

  const userTablePreferenceResponse = useAPI(
    currentUserId ? 'get' : null, // only make the request if we have the id
    `/api/v2/users/${currentUserId}/table_preferences/${tableName}`
  );

  const userTablePreferenceColumns =
    userTablePreferenceResponse.response?.columns;

  const hasPreference = !(
    userTablePreferenceResponse.response?.response?.status === 404
  );

  return {
    currentUserId,
    hasPreference,
    columns: userTablePreferenceColumns,
  };
};
