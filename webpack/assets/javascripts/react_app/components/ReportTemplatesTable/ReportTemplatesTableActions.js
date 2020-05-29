import { getTableItemsAction } from '../common/table';
import {
  REPORT_TEMPLATES_TABLE_CONTROLLER,
  REPORT_TEMPLATES_TABLE_ID,
} from './ReportTemplatesTableConstants';

export const getTableItems = query =>
  getTableItemsAction(REPORT_TEMPLATES_TABLE_ID, query, `../api/${REPORT_TEMPLATES_TABLE_CONTROLLER}`);
