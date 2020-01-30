import {
  column,
  headerFormatterWithProps,
  cellFormatter,
  cellFormatterWithProps,
} from '../../../../components/common/table';
import { translate as __ } from '../../../../common/I18n';

import {
  settingNameCellFormatter,
  settingValueCellFormatter,
} from './SettingsTableFormatters';

const createSettingsTableSchema = onEditClick => [
  column(
    'fullName',
    __('Name'),
    [headerFormatterWithProps],
    [settingNameCellFormatter, cellFormatterWithProps],
    { className: 'col-md-2' }
  ),
  column(
    'value',
    __('Value'),
    [headerFormatterWithProps],
    [settingValueCellFormatter(onEditClick), cellFormatterWithProps],
    { className: 'col-md-3' }
  ),
  column(
    'description',
    __('Description'),
    [headerFormatterWithProps],
    [cellFormatter]
  ),
];

export default createSettingsTableSchema;
