import { MODELS_TABLE_ID } from './ModelsTableConstants';
import { getTableItems } from './ModelsTableActions';

jest.mock('../common/table', () => ({
  getTableItemsAction: jest.fn((tableID, query) => `${tableID}-${query}`),
}));

describe('ModelsTable actions', () => {
  it('getTableItems should reuse common/table/getTableItemsAction', () => {
    const query = 'some-query';

    expect(getTableItems(query)).toEqual(`${MODELS_TABLE_ID}-${query}`);
  });
});
