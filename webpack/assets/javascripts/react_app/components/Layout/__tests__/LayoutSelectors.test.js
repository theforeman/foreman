import { patternflyMenuItemsSelector } from '../LayoutSelectors';
import { layoutMock } from '../Layout.fixtures';

const state = {
  layout: {
    items: layoutMock.data.menu,
    activeMenu: 'Hosts',
    currentOrganization: { title: 'org1' },
  },
};
describe('Layout Selectors', () => {
  it('should return PF-React Compatible items', () => {
    const output = patternflyMenuItemsSelector(state);

    expect(output).toMatchSnapshot();
  });
  it('should return empty array', () => {
    const emptyState = {
      layout: {
        items: [],
      },
    };
    const output = patternflyMenuItemsSelector(emptyState);

    expect(output).toMatchSnapshot();
  });
});
