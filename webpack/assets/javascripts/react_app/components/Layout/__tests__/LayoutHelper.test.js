import { combineMenuItems, getActive, handleMenuClick } from '../LayoutHelper';
import { layoutMock } from '../Layout.fixtures';

describe('LayoutHelper', () => {
  it('should combineMenuItems', () => {
    const combined = combineMenuItems(layoutMock.data);
    expect(combined).toMatchSnapshot();
  });
  it('should getActive(Monitor)', () => {
    const active = getActive(layoutMock.data.menu, '/fact_values');
    expect(active).toMatchSnapshot();
  });
  it('should handleMenuClick', () => {
    const change = jest.fn();
    handleMenuClick({ title: 'Host' }, 'Infra', change);
    expect(change).toHaveBeenCalled();
  });
});
