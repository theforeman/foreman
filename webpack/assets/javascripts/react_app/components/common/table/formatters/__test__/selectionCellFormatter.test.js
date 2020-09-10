import { selectionCellFormatter } from '../selectionCellFormatter';

describe('selectionCellFormatter', () => {
  it('render', () => {
    expect(
      selectionCellFormatter(
        { isSelected: () => true },
        { rowIndex: 'some-index' }
      )
    ).toMatchSnapshot();
  });
});
