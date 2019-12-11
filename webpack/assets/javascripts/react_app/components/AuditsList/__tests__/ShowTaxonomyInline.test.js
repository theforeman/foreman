import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import ShowTaxonomyInline from '../ShowTaxonomyInline';
import { TaxonomyProps } from './AuditsList.fixtures';
import { translate as __ } from '../../../common/I18n';

const OrgsFixtures = {
  'render organizations': {
    displayLabel: __('Affected Organizations'),
    items: TaxonomyProps.orgs,
  },
};

describe('ShowTaxonomyInline', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      ShowTaxonomyInline,
      OrgsFixtures
    );
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component).toMatchSnapshot();
      });
    });
  });
});
