import URI from 'urijs';
import {
  ellipsisCellFormatter,
  headerFormatterWithProps,
  sortableHeaderFormatter,
} from '../formatters';
import { column } from './column';

/**
 * Generate a sortable column for a patternfly-3 table.
 * See more in http://patternfly-react.surge.sh/patternfly-3/
 * See an example: ModelsTableSchema
 * @param  {String} property                 the property name of the table.
 * @param  {String} label                    the column label.
 * @param  {Number} mdWidth                  column size on medium devices. Note: using bootstrap
 *                                           grid convention.
 * @param  {Object} sortController           sortController object.
 *                                           See more in sortControllerFactory.
 * @param  {Array} additionalCellFormatters  array of functions that format column cells
 * @return {Object} the table column.
 */
export const sortableColumn = (
  property,
  label,
  mdWidth,
  sortController,
  additionalCellFormatters = []
) =>
  column(
    property,
    label,
    [sortableHeaderFormatter(sortController), headerFormatterWithProps],
    [...additionalCellFormatters, ellipsisCellFormatter],
    { sort: true, sortDirection: '', className: `col-md-${mdWidth}` }
  );

/**
 * Creates a sort controller for Patternfly-3 table.
 * @param  {Function} apiCall   a function that fetches and stores data into Redux.
 * @param  {String}   sortBy    the property that the table is sorted by.
 * @param  {String}   sortOrder the order which the table is sorted by.
 * @return {Object}   a sort controller object.
 */
export const sortControllerFactory = (apiCall, sortBy, sortOrder) => ({
  apply: (by, order) => {
    const uri = new URI(window.location.href);
    uri.setSearch('order', `${by} ${order}`);
    // FIXME(bshuster): Going back in the browser won't render the state.
    //                  Using react-router will fix this completely.
    window.history.pushState({ path: uri.toString() }, '', uri.toString());
    apiCall(uri.query(true));
  },
  property: sortBy,
  order: sortOrder,
});
