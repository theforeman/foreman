import { REPORT_TEMPLATES_TABLE_ID } from './ReportTemplatesTableConstants';
import { getTableItems } from './ReportTemplatesTableActions';

jest.mock('../common/table', () => ({
  getTableItemsAction: jest.fn((tableID, query) => `${tableID}-${query}`),
}));

describe('ReportTemplatesTable actions', () => {
  it('getTableItems should reuse common/table/getTableItemsAction', () => {
    const query = 'some-query';

    expect(getTableItems(query)).toEqual(`${REPORT_TEMPLATES_TABLE_ID}-${query}`);
  });
});
