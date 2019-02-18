import URI from '@theforeman/vendor/urijs';
import { ajaxRequestAction } from '../../../../redux/actions/common';

/**
 * An async Redux action that fetches and stores table data in Redux.
 * @param  {String} controller the controller name
 * @param  {Object} query      the API request query
 * @return {Function}          Redux Thunk function
 */
export const getTableItems = (controller, query) => dispatch => {
  const url = new URI(`/api/${controller}`);
  url.addSearch({ ...query, include_permissions: true });
  return ajaxRequestAction({
    dispatch,
    requestAction: `${controller.toUpperCase()}_TABLE_REQUEST`,
    successAction: `${controller.toUpperCase()}_TABLE_SUCCESS`,
    failedAction: `${controller.toUpperCase()}_TABLE_FAILURE`,
    url: url.toString(),
    item: { controller, url: url.toString() },
  });
};
