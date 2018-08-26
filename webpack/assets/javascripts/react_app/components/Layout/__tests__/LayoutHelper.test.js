import { combineMenuItems, getActiveOnBack } from '../LayoutHelper';
import { layoutMock } from '../Layout.fixtures';

describe('LayoutHelper', () => {
  it('should combineMenuItems', () => {
    const combined = combineMenuItems(layoutMock.data);
    expect(combined).toMatchSnapshot();
  });
  it('should getActiveOnBack(Monitor)', () => {
    const active = getActiveOnBack(layoutMock.data.menu, '/fact_values');
    expect(active).toMatchSnapshot();
  });
});
