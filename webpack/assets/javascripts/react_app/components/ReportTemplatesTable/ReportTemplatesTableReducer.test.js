import { REPORT_TEMPLATES_TABLE_ID } from './ReportTemplatesTableConstants';
import reducer from './ReportTemplatesTableReducer';

jest.mock('../common/table', () => ({
  createTableReducer: jest.fn(controller => controller),
}));

describe('ReportTemplatesTable reducer', () => {
  it('should reuse createTableReducer', () => {
    expect(reducer).toEqual(REPORT_TEMPLATES_TABLE_ID);
  });
});
