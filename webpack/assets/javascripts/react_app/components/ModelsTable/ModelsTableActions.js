import { getTableItemsAction, changeTablePage } from '../common/table';
import {
  MODELS_TABLE_CONTROLLER,
  MODELS_TABLE_ID,
} from './ModelsTableConstants';
import { updateURLQuery } from '../../common/urlHelpers';

export const getTableItems = query =>
  getTableItemsAction(MODELS_TABLE_ID, query, `api/${MODELS_TABLE_CONTROLLER}`);

export const onPaginationChange = ({ page, perPage }) => {
  updateURLQuery({
    page,
    per_page: perPage,
  });
  return changeTablePage(MODELS_TABLE_ID, { page, perPage });
};
