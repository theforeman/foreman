import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import SearchLink from '../SearchLink';

import { searchLinkProp } from './AuditsList.fixtures';

const searchLinkFixture = {
  'render a search link': searchLinkProp,
};

describe('SearchLink', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      SearchLink,
      searchLinkFixture
    );
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component).toMatchSnapshot();
      });
    });
  });
});
