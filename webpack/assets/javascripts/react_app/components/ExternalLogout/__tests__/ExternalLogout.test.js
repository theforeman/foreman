import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import ExternalLogout from '../ExternalLogout';
import { props } from '../ExternalLogout.fixtures';

const fixtures = {
  'renders ExternalLogout': props,
};
describe('ExternalLogout', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ExternalLogout, fixtures);
  });
});
