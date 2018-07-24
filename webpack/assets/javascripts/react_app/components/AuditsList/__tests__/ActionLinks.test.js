import toJson from 'enzyme-to-json';
import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import ActionLinks from '../ActionLinks';

import { actionsList } from './AuditsList.fixtures';

const actionLinksFixture = {
  'render action links': { allowedActions: actionsList },
};

describe('ActionLinks', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(ActionLinks, actionLinksFixture);
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component.find('a').length).toEqual(1);
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
