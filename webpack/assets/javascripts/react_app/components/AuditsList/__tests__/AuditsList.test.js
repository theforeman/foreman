import toJson from 'enzyme-to-json';
import { shallowRenderComponentWithFixtures } from '../../../common/testHelpers';
import AuditsList from '../../AuditsList';

import { AuditsProps } from './AuditsList.fixtures';

const auditsFixtures = {
  'render resources list': { ...AuditsProps },
};

describe('AuditsList', () => {
  describe('rendering', () => {
    const components = shallowRenderComponentWithFixtures(
      AuditsList,
      auditsFixtures
    );
    components.forEach(({ description, component }) => {
      it(description, () => {
        expect(toJson(component)).toMatchSnapshot();
      });
    });
  });
});
