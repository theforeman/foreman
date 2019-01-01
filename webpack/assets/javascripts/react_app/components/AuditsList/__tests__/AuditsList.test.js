import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import AuditsList from '../../AuditsList';

import { AuditsProps } from './AuditsList.fixtures';

const auditsFixtures = {
  'render resources list': {
    data: { ...AuditsProps },
    fetchAndPush: jest.fn(),
  },
};

describe('AuditsList', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      AuditsList,
      auditsFixtures
    );
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(component).toMatchSnapshot();
      });
    });
  });
});
