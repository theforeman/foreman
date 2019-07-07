import URI from 'urijs';
import { ajaxRequestAction } from '../../../../redux/actions/common';
import createTableActionTypes from '../actionsHelpers/actionTypeCreator';

/**
 * An async Redux action that fetches and stores table data in Redux.
 * @param  {String} tableID    the table ID for Redux
 * @param  {Object} query      the API request query
 * @param  {String} url        the url for the data
 * @return {Function}          Redux Thunk function
 */
const getTableItemsAction = (tableID, query, fetchUrl) => dispatch => {
  const url = new URI(fetchUrl);
  url.addSearch({ ...query, include_permissions: true });

  const ACTION_TYPES = createTableActionTypes(tableID);

  return ajaxRequestAction({
    dispatch,
    requestAction: ACTION_TYPES.REQUEST,
    successAction: ACTION_TYPES.SUCCESS,
    failedAction: ACTION_TYPES.FAILURE,
    url: url.toString(),
    item: { tableID, url: url.toString() },
  });
};

export default getTableItemsAction;
