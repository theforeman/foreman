import { getTableItemsAction } from '../common/table';
import {
  MODELS_TABLE_CONTROLLER,
  MODELS_TABLE_ID,
} from './ModelsTableConstants';

export const getTableItems = query =>
  getTableItemsAction(MODELS_TABLE_ID, query, `api/${MODELS_TABLE_CONTROLLER}`);
