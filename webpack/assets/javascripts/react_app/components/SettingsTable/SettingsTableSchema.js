import {
  column,
  headerFormatterWithProps,
  cellFormatterWithProps,
  translatedCellFormatter,
} from '../common/table';
import { translate as __ } from '../../common/I18n';

import {
  settingNameCellFormatter,
  settingValueCellFormatter,
} from './SettingsTableFormatters';

const createSettingsTableSchema = [
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
    [settingValueCellFormatter, cellFormatterWithProps],
    { className: 'col-md-3' }
  ),
  column(
    'description',
    __('Description'),
    [headerFormatterWithProps],
    [translatedCellFormatter]
  ),
];

export default createSettingsTableSchema;
