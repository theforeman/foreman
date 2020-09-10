import URI from 'urijs';
import { get } from './../../../../redux/API';
/**
 * An async Redux action that fetches and stores table data in Redux.
 * @param  {String} tableID    the table ID for Redux
 * @param  {Object} query      the API request query
 * @param  {String} url        the url for the data
 * @return {Function}          Redux Thunk function
 */
const getTableItemsAction = (tableID, query, fetchUrl) => {
  const url = new URI(fetchUrl);
  url.addSearch({ ...query, include_permissions: true });

  return get({
    key: tableID.toUpperCase(),
    url: url.toString(),
    payload: { tableID, url: url.toString() },
  });
};

export default getTableItemsAction;
