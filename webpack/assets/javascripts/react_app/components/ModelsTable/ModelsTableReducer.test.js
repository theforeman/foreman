import { MODELS_TABLE_ID } from './ModelsTableConstants';
import reducer from './ModelsTableReducer';

jest.mock('../common/table', () => ({
  createTableReducer: jest.fn(controller => controller),
}));

describe('ModelsTable reducer', () => {
  it('should reuse createTableReducer', () => {
    expect(reducer).toEqual(MODELS_TABLE_ID);
  });
});
