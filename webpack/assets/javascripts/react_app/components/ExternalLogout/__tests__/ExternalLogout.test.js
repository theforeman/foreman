import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
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
