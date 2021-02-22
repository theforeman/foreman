import LoginPage from '../LoginPage';
import { props } from '../LoginPage.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders LoginPage': props,
};
describe('LoginPage', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(LoginPage, fixtures);
  });
});
