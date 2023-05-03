import {
  createInitialTaxonomy,
  combineMenuItems,
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
});
