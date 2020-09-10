import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import ShowOrgsLocs from '../ShowOrgsLocs';

import { TaxonomyProps } from './AuditsList.fixtures';

const ShowOrgsLocsFixtures = {
  'render organizations and locations': { ...TaxonomyProps },
};

describe('ShowOrgsLocs', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      ShowOrgsLocs,
      ShowOrgsLocsFixtures
    );
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component).toMatchSnapshot();
      });
    });
  });
});
