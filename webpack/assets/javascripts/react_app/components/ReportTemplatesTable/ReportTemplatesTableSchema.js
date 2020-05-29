import { translate as __ } from '../../common/I18n';
import {
  sortControllerFactory,
  column,
  sortableColumn,
  headerFormatterWithProps,
  cellFormatterWithProps,
  nameCellFormatter,
  snippetCellFormatter,
  lockedCellFormatter,
  templateActionCellFormatter,
  cellFormatter,
} from '../common/table';

/**
 * Generate a table schema to the Report Templates page.
 * @param  {Function} apiCall a Redux async action that fetches and stores table data in Redux.
 *                            See ReportTemplatesTableActions.
 * @param  {String}   by      by which column the table is sorted.
 *                            If none then set it to undefined/null.
 * @param  {String}   order   in what order to sort a column. If none then set it to undefined/null.
 *                            Otherwise, 'ASC' for ascending and 'DESC' for descending
 * @return {Array}
 */
const createReportTemplatesTableSchema = (
  apiCall,
  by,
  order,
  availableActions,
) => {
  const sortController = sortControllerFactory(apiCall, by, order);
  return [
    sortableColumn('name', __('Name'), 3, sortController, [
      nameCellFormatter('templates/report_templates'),
    ]),
    sortableColumn('snippet', __('Snippet'), 1, sortController, [
      snippetCellFormatter(),
    ]),
    sortableColumn('locked', __('Locked'), 1, sortController, [
      lockedCellFormatter(),
    ]),
    column(
      'available_actions',
      __('Actions'),
      [headerFormatterWithProps],
      [templateActionCellFormatter(availableActions)],
      { className: 'col-md-1' },
    ),
  ];
};

export default createReportTemplatesTableSchema;
