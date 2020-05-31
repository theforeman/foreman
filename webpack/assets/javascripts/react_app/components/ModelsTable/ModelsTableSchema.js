import { translate as __ } from '../../common/I18n';
import {
  sortControllerFactory,
  column,
  sortableColumn,
  headerFormatterWithProps,
  cellFormatterWithProps,
  nameCellFormatter,
  hostsCountCellFormatter,
  deleteActionCellFormatter,
  cellFormatter,
  selectionHeaderCellFormatter,
  selectionCellFormatter,
} from '../common/table';

/**
 * Generate a table schema to the Hardware Models page.
 * @param  {Function} apiCall a Redux async action that fetches and stores table data in Redux.
 *                            See ModelsTableActions.
 * @param  {String}   by      by which column the table is sorted.
 *                            If none then set it to undefined/null.
 * @param  {String}   order   in what order to sort a column. If none then set it to undefined/null.
 *                            Otherwise, 'ASC' for ascending and 'DESC' for descending
 * @return {Array}
 */
const createModelsTableSchema = (apiCall, by, order, selectionController) => {
  const sortController = sortControllerFactory(apiCall, by, order);
  return [
    column(
      '',
      'Select all rows',
      [label => selectionHeaderCellFormatter(selectionController, label)],
      [
        (value, additionalData) =>
          selectionCellFormatter(selectionController, additionalData),
      ]
    ),
    sortableColumn('name', __('Name'), 4, sortController, [
      nameCellFormatter('models'),
    ]),
    sortableColumn('vendor_class', __('Vendor Class'), 3, sortController),
    sortableColumn('hardware_model', __('Hardware Model'), 3, sortController),
    column(
      'hosts_count',
      __('Hosts'),
      [headerFormatterWithProps],
      [hostsCountCellFormatter('model'), cellFormatterWithProps],
      { className: 'col-md-1' },
      { align: 'right' }
    ),
    column(
      'actions',
      __('Actions'),
      [headerFormatterWithProps],
      [deleteActionCellFormatter('models'), cellFormatter]
    ),
  ];
};

export default createModelsTableSchema;
