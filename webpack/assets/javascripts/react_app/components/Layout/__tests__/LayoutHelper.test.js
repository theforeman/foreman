import {
  createInitialTaxonomy,
  combineMenuItems,
  getActiveMenuItem,
  handleMenuClick,
} from '../LayoutHelper';
import { layoutMock } from '../Layout.fixtures';

describe('LayoutHelper', () => {
  it('should createInitialTaxonomy', () => {
    const availableTaxonomies = [
      { id: 1, title: 'Taxonomy 1' },
      { id: 2, title: 'Taxonomy 2' },
    ];
    const [, tax2] = availableTaxonomies;
    const taxonomy = createInitialTaxonomy(tax2.title, availableTaxonomies);
    expect(taxonomy).toEqual(tax2);
  });
  it('should combineMenuItems', () => {
    const combined = combineMenuItems(layoutMock.data);
    expect(combined).toMatchSnapshot();
  });
  it('should getActiveMenuItem(Monitor, null)', () => {
    const active = getActiveMenuItem(layoutMock.data.menu);
    expect(active).toMatchSnapshot();
  });
  it('should getActiveMenuItem(Hosts, "/hosts/new")', () => {
    const active = getActiveMenuItem(layoutMock.data.menu, '/hosts/new');
    expect(active).toMatchSnapshot();
  });
  it('should getActiveMenuItem(null)', () => {
    const active = getActiveMenuItem([{ children: [] }], '/fact_values');
    expect(active).toMatchSnapshot();
  });
  it('should handleMenuClick', () => {
    const change = jest.fn();
    handleMenuClick({ title: 'Host' }, 'Infra', change);
    expect(change).toHaveBeenCalled();
  });
  it('should handleMenuClick on the current menu', () => {
    const change = jest.fn();
    handleMenuClick({ title: 'Host' }, 'Host', change);
    expect(change).not.toHaveBeenCalled();
  });
});
