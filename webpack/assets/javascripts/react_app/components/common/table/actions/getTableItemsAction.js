import URI from 'urijs';
import { ajaxRequestAction } from '../../../../redux/actions/common';
import createTableActionTypes from '../actionsHelpers/actionTypeCreator';

/**
 * An async Redux action that fetches and stores table data in Redux.
 * @param  {String} controller the controller name
 * @param  {Object} query      the API request query
 * @return {Function}          Redux Thunk function
 */
const getTableItemsAction = (controller, query) => dispatch => {
  const url = new URI(`/api/${controller}`);
  url.addSearch({ ...query, include_permissions: true });

  const ACTION_TYPES = createTableActionTypes(controller);

  return ajaxRequestAction({
    dispatch,
    requestAction: ACTION_TYPES.REQUEST,
    successAction: ACTION_TYPES.SUCCESS,
    failedAction: ACTION_TYPES.FAILURE,
    url: url.toString(),
    item: { controller, url: url.toString() },
  });
};

export default getTableItemsAction;
