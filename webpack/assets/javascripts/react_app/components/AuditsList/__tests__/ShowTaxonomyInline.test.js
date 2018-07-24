import toJson from 'enzyme-to-json';
import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import ShowTaxonomyInline from '../ShowTaxonomyInline';
import { TaxonomyProps } from './AuditsList.fixtures';

const OrgsFixtures = {
  'render organizations': {
    displayLabel: __('Affected Organizations'),
    items: TaxonomyProps.orgs,
  },
};

describe('ShowTaxonomyInline', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(ShowTaxonomyInline, OrgsFixtures);
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
