import {
  MODELS_TABLE_ID,
  MODELS_TABLE_CONTROLLER,
} from './ModelsTableConstants';
import { getTableItems, onPaginationChange } from './ModelsTableActions';
import { getTableItemsAction, changeTablePage } from '../common/table';
import { updateURLQuery } from '../../common/urlHelpers';

jest.mock('../common/table');
jest.mock('../../common/urlHelpers');
getTableItemsAction.mockImplementation(jest.fn());
changeTablePage.mockImplementation(jest.fn());
updateURLQuery.mockImplementation(jest.fn());
describe('ModelsTable actions', () => {
  it('getTableItems should reuse common/table/getTableItemsAction', () => {
    const query = 'some-query';
    getTableItems(query);
    expect(getTableItemsAction).toBeCalledWith(
      MODELS_TABLE_ID,
      query,
      `api/${MODELS_TABLE_CONTROLLER}`
    );
  });

  it('should onPaginationChange', () => {
    const pagination = { page: 2, perPage: 5 };
    onPaginationChange(pagination);
    expect(changeTablePage).toBeCalledWith(MODELS_TABLE_ID, pagination);
    expect(updateURLQuery).toBeCalledWith({
      page: pagination.page,
      per_page: pagination.perPage,
    });
  });
});
