import LoginPage from '../LoginPage';
import { props, propsWithOidc } from '../LoginPage.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'renders LoginPage': props,
  'renders LoginPage with OIDC providers': propsWithOidc,
};
describe('LoginPage', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(LoginPage, fixtures);
  });
});
