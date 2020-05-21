import { selectionHeaderCellFormatter } from '../selectionHeaderCellFormatter';

describe('selectionHeaderCellFormatter', () => {
  it('render', () => {
    expect(
      selectionHeaderCellFormatter(
        { allPageSelected: () => true },
        'some-label'
      )
    ).toMatchSnapshot();
  });
});
