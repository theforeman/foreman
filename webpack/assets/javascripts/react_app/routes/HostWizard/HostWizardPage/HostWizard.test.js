import HostWizard from './HostWizard';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const props = {};
const fixtures = {
  'renders LoginPage': props,
};

describe('HostWizard', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(HostWizard, fixtures);
  });
});
